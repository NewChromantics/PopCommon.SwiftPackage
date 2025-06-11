import Vision
import CoreImage
import CoreImage.CIFilterBuiltins
import PopCommon
import Combine


public struct FrameMarker : Identifiable, Codable, Equatable
{
	public var id : String	{label}
	public var label : String
	public var position : CGPoint
	static var quantMax : Double { 65535 }
	
	static func WithLabel(_ label:String,_ point:CGPoint) -> FrameMarker
	{
		return FrameMarker(label: label, position: point)
	}

	static func Dequantize(x:UInt16,y:UInt16) -> CGPoint
	{
		let xf = Double(x) / FrameMarker.quantMax
		let yf = Double(y) / FrameMarker.quantMax
		return CGPoint(x:xf,y:yf)
	}
	
	func Quantize() -> (UInt16,UInt16)
	{
		var xf = Double(self.position.x) * FrameMarker.quantMax
		var yf = Double(self.position.y) * FrameMarker.quantMax
		xf = max( 0.0, min( FrameMarker.quantMax, xf ) )
		yf = max( 0.0, min( FrameMarker.quantMax, yf ) )
		let x16 = UInt16(xf)
		let y16 = UInt16(yf)
		return (x16,y16)
	}
	
}



func VisionHandKeyToNiceKey(_ HandKey:String,handIndex:Int) -> String?
{
	let prefix = "hand\(handIndex)_"
	switch HandKey
	{
		case "TTIP":	return "\(prefix)thumb_0"	//	tip
		case "TIP":		return "\(prefix)thumb_1"	//	Interphalangeal Joint
		case "TMP":		return "\(prefix)thumb_2"	//	Metacarpophalangeal
		case "TCMC":	return "\(prefix)thumb_3"	//	Carpometacarpal Joint (side of hand)
			
		case "ITIP":	return "\(prefix)index_0"	//	tip
		case "IDIP":	return "\(prefix)index_1"	//	Distal Interphalangeal Joint
		case "IPIP":	return "\(prefix)index_2"	//	Proximal Interphalangeal Joint
		case "IMCP":	return "\(prefix)index_3"	//	Metacarpophalangeal Joint
			
		case "MCMC":	return "\(prefix)middle_cmc"
		case "MMP":		return "\(prefix)middle_mid_point"
		case "MIP":		return "\(prefix)middle_ip_point"
		case "MTIP":	return "\(prefix)middle_tip"
			
			
		case "RCMC":	return "\(prefix)ring_cmc"
		case "RMP":		return "\(prefix)ring_mid_point"
		case "RIP":		return "\(prefix)ring_ip_point"
		case "RTIP":	return "\(prefix)ring_tip"
		case "PCMC":	return "\(prefix)pinky_cmc"
		case "PMP":		return "\(prefix)pinky_mid_point"
		case "PIP":		return "\(prefix)pinky_ip_point"
		case "PTIP":	return "\(prefix)pinky_tip"
		case "WRI":		return "\(prefix)wrist"
			
		default:	return nil
	}
}


//	rename some face landmarks to match a body-pose-joint
func VisionFaceKeyToJointKey(_ FaceLandmarkKey:String) -> String?
{
	switch FaceLandmarkKey
	{
		case "leftEye0":	return "left_eye_joint"
		case "rightEye0":	return "right_eye_joint"
		default:	return nil
	}
}


public func GetFaceMarkers(faceRequest:VNDetectFaceLandmarksRequest) -> [FrameMarker]
{
	guard let landmarks = faceRequest.results?.first?.landmarks else
	{
		return []
	}
	let faceMeta = faceRequest.results!.first!
	
	//	pos is normalised to bounds
	//	expand to be normalised to image
	let boundingBox = faceMeta.boundingBox
	
	var markers = [FrameMarker]()
	markers += landmarks.faceContour?.normalizedPoints.enumerated().map{FrameMarker.WithLabel("face\($0)",boundingBox.expandNormalised($1))} ?? []
	markers += landmarks.leftEye?.normalizedPoints.enumerated().map{FrameMarker.WithLabel("leftEye\($0)",boundingBox.expandNormalised($1))} ?? []
	markers += landmarks.rightEye?.normalizedPoints.enumerated().map{FrameMarker.WithLabel("rightEye\($0)",boundingBox.expandNormalised($1))} ?? []
	markers += landmarks.leftEyebrow?.normalizedPoints.enumerated().map{FrameMarker.WithLabel("leftEyebrow\($0)",boundingBox.expandNormalised($1))} ?? []
	markers += landmarks.rightEyebrow?.normalizedPoints.enumerated().map{FrameMarker.WithLabel("rightEyebrow\($0)",boundingBox.expandNormalised($1))} ?? []
	markers += landmarks.nose?.normalizedPoints.enumerated().map{FrameMarker.WithLabel("nose\($0)",boundingBox.expandNormalised($1))} ?? []
	markers += landmarks.noseCrest?.normalizedPoints.enumerated().map{FrameMarker.WithLabel("noseCrest\($0)",boundingBox.expandNormalised($1))} ?? []
	markers += landmarks.medianLine?.normalizedPoints.enumerated().map{FrameMarker.WithLabel("medianLine\($0)",boundingBox.expandNormalised($1))} ?? []
	markers += landmarks.outerLips?.normalizedPoints.enumerated().map{FrameMarker.WithLabel("outerLips\($0)",boundingBox.expandNormalised($1))} ?? []
	markers += landmarks.innerLips?.normalizedPoints.enumerated().map{FrameMarker.WithLabel("innerLips\($0)",boundingBox.expandNormalised($1))} ?? []
	markers += landmarks.leftPupil?.normalizedPoints.enumerated().map{FrameMarker.WithLabel("leftPupil\($0)",boundingBox.expandNormalised($1))} ?? []
	markers += landmarks.rightPupil?.normalizedPoints.enumerated().map{FrameMarker.WithLabel("rightPupil\($0)",boundingBox.expandNormalised($1))} ?? []
	
	//	rename some keys
	markers = markers.compactMap
	{
		_marker in
		var marker = _marker
		marker.label = VisionFaceKeyToJointKey(marker.label) ?? marker.label
		return marker
	}
	
	return markers
}

@available(macOS 11.0, *)
public func GetBodyMarkers(bodyRequest:VNDetectHumanBodyPoseRequest) -> [FrameMarker]
{
	guard let bodyMeta = bodyRequest.results?.first else
	{
		return []
	}
	
	var markers = [FrameMarker]()
	
	let groups = bodyMeta.availableGroupKeys
	for group in groups
	{
		do
		{
			let points : [VNRecognizedPointKey : VNRecognizedPoint] = try bodyMeta.recognizedPoints(forGroupKey: group)
			let groupMarkers = points.compactMap
			{
				pointEntry -> FrameMarker? in
				let pointName = pointEntry.key.rawValue
				let point = pointEntry.value
				let found = point.confidence > 0.1
				if !found
				{
					return nil
				}
				let x = point.x
				let y = point.y
				let pos = CGPoint(x:x,y:y)
				return FrameMarker( label:pointName, position:pos )
			}
			markers += groupMarkers
		}
		catch let error
		{
			print(error.localizedDescription)
		}
	}
	return markers
}

@available(macOS 11.0, *)
public func GetHandMarkers(bodyRequest:VNDetectHumanHandPoseRequest) -> [FrameMarker]
{
	//	as? from here https://developer.apple.com/videos/play/wwdc2020/10653/
	guard let handResults = bodyRequest.results else
	{
		return []
	}
	
	
	var markers = [FrameMarker]()
	
	for handIndex in 0..<handResults.count
	{
		let result = handResults[handIndex]
		
		//let groups = result.availableGroupKeys
		//for group in groups
		let group = VNRecognizedPointGroupKey.all
		if true
		{
			do
			{
				let points = try result.recognizedPoints(forGroupKey: group)
				let groupMarkers = points.compactMap
				{
					pointEntry -> FrameMarker? in
					var pointName = pointEntry.key.rawValue
					if ( pointName.hasPrefix("VNHLK") )
					{
						pointName = String( pointName.dropFirst("VNHLK".count) )
						pointName = VisionHandKeyToNiceKey(pointName,handIndex: handIndex) ?? pointName
					}
					else
					{
						print("not prefixed VNHLK=\(pointName)")
					}
					
					let point = pointEntry.value
					let found = point.confidence > 0.1
					if !found
					{
						return nil
					}
					let x = point.x
					let y = point.y
					let pos = CGPoint(x:x,y:y)
					return FrameMarker( label:pointName, position:pos )
				}
				markers += groupMarkers
			}
			catch let error
			{
				print(error.localizedDescription)
			}
		}
	}
	return markers
}


public func GetImageMarkers(input:CVPixelBuffer,body:Bool,face:Bool,hands:Bool) async throws -> [FrameMarker]
{
	//	even this causing leaks
	//return [FrameMarker]()
	//	https://forums.developer.apple.com/forums/thread/724940
	//	[Espresso::handle_ex_plan] exception=ANECF error: failed to load ANE model file:///System/Library/Frameworks/Vision.framework/Resources/landmarksflow-gwkf986dmy_63053_plus_8dtz95rnyx_quantized.espresso.net Error=_ANEEspressoIRTranslator : error Espresso exception: "I/O error": Cannot open additional blob file
	//	In case someone stumble on this, the issue was actually with flexible input dimension, same model with fixed input shapes is behaving as expected
	
	let handler = VNImageRequestHandler(cvPixelBuffer: input)
	
	let InputWidth = CVPixelBufferGetWidth(input)
	let InputHeight = CVPixelBufferGetHeight(input)
	let InputFormat = CVPixelBufferGetPixelFormatName(pixelBuffer:input)
	
	do
	{
		var markers = [FrameMarker]()
		var requestSkeletonResults : [Any]?
		
		let requestFace = VNDetectFaceLandmarksRequest()
		if #available(macOS 11.0, *) 
		{
			let requestSkeleton = VNDetectHumanBodyPoseRequest()
			let requestHand = VNDetectHumanHandPoseRequest()
			//requestHand.maximumHandCount = 2
			if body
			{
				try handler.perform([requestSkeleton])
				requestSkeletonResults = requestSkeleton.results
				markers += GetBodyMarkers(bodyRequest: requestSkeleton)
			}
			
			if hands
			{
				try handler.perform([requestHand])
				markers += GetHandMarkers(bodyRequest: requestHand)
			}
		}
		else 
		{
			// Fallback on earlier versions
		}
		
		
		//	if the skeleton failed - user may be too close - do a face run
		let faceFallback = body && (requestSkeletonResults?.isEmpty ?? true)
		if face || faceFallback
		{
			try handler.perform([requestFace])
			markers += GetFaceMarkers(faceRequest: requestFace)
		}
		
		//	flip output so y0=top
		markers = markers.compactMap
		{
			_marker in
			var marker = _marker
			marker.position.y = 1.0 - marker.position.y
			return marker
		}
		
		
		return markers
	}
	catch let error
	{
		throw RuntimeError("Failed to get face markers from image \(InputWidth)x\(InputHeight)[\(InputFormat)] \(error.localizedDescription)")
	}
}
