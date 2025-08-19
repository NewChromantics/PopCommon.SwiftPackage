import CoreMedia
import CoreImage
import simd
import Accelerate
import UniformTypeIdentifiers

public func CVGetErrorString(error:CVReturn) -> String
{
	switch error 
	{
		case kCVReturnSuccess:	return "kCVReturnSuccess"
		case kCVReturnInvalidArgument: return "kCVReturnInvalidArgument"
		case kCVReturnAllocationFailed: return "kCVReturnAllocationFailed"
		case kCVReturnUnsupported: return "kCVReturnUnsupported"
		case kCVReturnInvalidDisplay: return "kCVReturnInvalidDisplay"
		case kCVReturnDisplayLinkAlreadyRunning: return "kCVReturnDisplayLinkAlreadyRunning"
		case kCVReturnDisplayLinkNotRunning: return "kCVReturnDisplayLinkNotRunning"
		case kCVReturnDisplayLinkCallbacksNotSet: return "kCVReturnDisplayLinkCallbacksNotSet"
		case kCVReturnInvalidPixelFormat: return "kCVReturnInvalidPixelFormat"
		case kCVReturnInvalidSize: return "kCVReturnInvalidSize"
		case kCVReturnInvalidPixelBufferAttributes: return "kCVReturnInvalidPixelBufferAttributes"
		case kCVReturnPixelBufferNotOpenGLCompatible: return "kCVReturnPixelBufferNotOpenGLCompatible"
		case kCVReturnPixelBufferNotMetalCompatible: return "kCVReturnPixelBufferNotMetalCompatible"
		case kCVReturnWouldExceedAllocationThreshold: return "kCVReturnWouldExceedAllocationThreshold"
		case kCVReturnPoolAllocationFailed: return "kCVReturnPoolAllocationFailed"
		case kCVReturnInvalidPoolAttributes: return "kCVReturnInvalidPoolAttributes"
		case kCVReturnRetry: return "kCVReturnRetry"
		case kCVReturnError:	return "kCVReturnError(Undefined error)"	//	unspecified error
		default: return "\(error)"
	}
}


public func CVPixelBufferGetPixelFormatName(pixelBuffer: CVPixelBuffer) -> String {
	let p = CVPixelBufferGetPixelFormatType(pixelBuffer)
	return CVPixelBufferGetPixelFormatName(p)
}


public func CVPixelBufferGetPixelFormatName(_ format: CMPixelFormatType) -> String {
    switch format {
    case kCVPixelFormatType_1Monochrome:                   return "kCVPixelFormatType_1Monochrome"
    case kCVPixelFormatType_2Indexed:                      return "kCVPixelFormatType_2Indexed"
    case kCVPixelFormatType_4Indexed:                      return "kCVPixelFormatType_4Indexed"
    case kCVPixelFormatType_8Indexed:                      return "kCVPixelFormatType_8Indexed"
    case kCVPixelFormatType_1IndexedGray_WhiteIsZero:      return "kCVPixelFormatType_1IndexedGray_WhiteIsZero"
    case kCVPixelFormatType_2IndexedGray_WhiteIsZero:      return "kCVPixelFormatType_2IndexedGray_WhiteIsZero"
    case kCVPixelFormatType_4IndexedGray_WhiteIsZero:      return "kCVPixelFormatType_4IndexedGray_WhiteIsZero"
    case kCVPixelFormatType_8IndexedGray_WhiteIsZero:      return "kCVPixelFormatType_8IndexedGray_WhiteIsZero"
    case kCVPixelFormatType_16BE555:                       return "kCVPixelFormatType_16BE555"
    case kCVPixelFormatType_16LE555:                       return "kCVPixelFormatType_16LE555"
    case kCVPixelFormatType_16LE5551:                      return "kCVPixelFormatType_16LE5551"
    case kCVPixelFormatType_16BE565:                       return "kCVPixelFormatType_16BE565"
    case kCVPixelFormatType_16LE565:                       return "kCVPixelFormatType_16LE565"
    case kCVPixelFormatType_24RGB:                         return "kCVPixelFormatType_24RGB"
    case kCVPixelFormatType_24BGR:                         return "kCVPixelFormatType_24BGR"
    case kCVPixelFormatType_32ARGB:                        return "kCVPixelFormatType_32ARGB"
    case kCVPixelFormatType_32BGRA:                        return "kCVPixelFormatType_32BGRA"
    case kCVPixelFormatType_32ABGR:                        return "kCVPixelFormatType_32ABGR"
    case kCVPixelFormatType_32RGBA:                        return "kCVPixelFormatType_32RGBA"
    case kCVPixelFormatType_64ARGB:                        return "kCVPixelFormatType_64ARGB"
    case kCVPixelFormatType_48RGB:                         return "kCVPixelFormatType_48RGB"
    case kCVPixelFormatType_32AlphaGray:                   return "kCVPixelFormatType_32AlphaGray"
    case kCVPixelFormatType_16Gray:                        return "kCVPixelFormatType_16Gray"
    case kCVPixelFormatType_30RGB:                         return "kCVPixelFormatType_30RGB"
    case kCVPixelFormatType_422YpCbCr8:                    return "kCVPixelFormatType_422YpCbCr8"
    case kCVPixelFormatType_4444YpCbCrA8:                  return "kCVPixelFormatType_4444YpCbCrA8"
    case kCVPixelFormatType_4444YpCbCrA8R:                 return "kCVPixelFormatType_4444YpCbCrA8R"
    case kCVPixelFormatType_4444AYpCbCr8:                  return "kCVPixelFormatType_4444AYpCbCr8"
    case kCVPixelFormatType_4444AYpCbCr16:                 return "kCVPixelFormatType_4444AYpCbCr16"
    case kCVPixelFormatType_444YpCbCr8:                    return "kCVPixelFormatType_444YpCbCr8"
    case kCVPixelFormatType_422YpCbCr16:                   return "kCVPixelFormatType_422YpCbCr16"
    case kCVPixelFormatType_422YpCbCr10:                   return "kCVPixelFormatType_422YpCbCr10"
    case kCVPixelFormatType_444YpCbCr10:                   return "kCVPixelFormatType_444YpCbCr10"
    case kCVPixelFormatType_420YpCbCr8Planar:              return "kCVPixelFormatType_420YpCbCr8Planar"
    case kCVPixelFormatType_420YpCbCr8PlanarFullRange:     return "kCVPixelFormatType_420YpCbCr8PlanarFullRange"
    case kCVPixelFormatType_422YpCbCr_4A_8BiPlanar:        return "kCVPixelFormatType_422YpCbCr_4A_8BiPlanar"
    case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:  return "kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange"
    case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange:   return "kCVPixelFormatType_420YpCbCr8BiPlanarFullRange"
    case kCVPixelFormatType_422YpCbCr8_yuvs:               return "kCVPixelFormatType_422YpCbCr8_yuvs"
    case kCVPixelFormatType_422YpCbCr8FullRange:           return "kCVPixelFormatType_422YpCbCr8FullRange"
    case kCVPixelFormatType_OneComponent8:                 return "kCVPixelFormatType_OneComponent8"
    case kCVPixelFormatType_TwoComponent8:                 return "kCVPixelFormatType_TwoComponent8"
    case kCVPixelFormatType_30RGBLEPackedWideGamut:        return "kCVPixelFormatType_30RGBLEPackedWideGamut"
    case kCVPixelFormatType_OneComponent16Half:            return "kCVPixelFormatType_OneComponent16Half"
    case kCVPixelFormatType_OneComponent32Float:           return "kCVPixelFormatType_OneComponent32Float"
    case kCVPixelFormatType_TwoComponent16Half:            return "kCVPixelFormatType_TwoComponent16Half"
    case kCVPixelFormatType_TwoComponent32Float:           return "kCVPixelFormatType_TwoComponent32Float"
    case kCVPixelFormatType_64RGBAHalf:                    return "kCVPixelFormatType_64RGBAHalf"
    case kCVPixelFormatType_128RGBAFloat:                  return "kCVPixelFormatType_128RGBAFloat"
    case kCVPixelFormatType_14Bayer_GRBG:                  return "kCVPixelFormatType_14Bayer_GRBG"
    case kCVPixelFormatType_14Bayer_RGGB:                  return "kCVPixelFormatType_14Bayer_RGGB"
    case kCVPixelFormatType_14Bayer_BGGR:                  return "kCVPixelFormatType_14Bayer_BGGR"
    case kCVPixelFormatType_14Bayer_GBRG:                  return "kCVPixelFormatType_14Bayer_GBRG"
		case kCVPixelFormatType_DepthFloat32:				return "kCVPixelFormatType_DepthFloat32"
    default: return "CVPixelFormat_Unknown_\(format)"
    }
}


public extension vImage_ARGBToYpCbCrMatrix
{
	//	get a simple 3x3 matrix for shaders etc to use
	var rgbToYuv : simd_float3x3
	{
		//	https://developer.apple.com/documentation/accelerate/vimage_argbtoypcbcrmatrix
		let row0 = simd_float3( R_Yp, G_Yp, B_Yp )
		let row1 = simd_float3( R_Cb, G_Cb, B_Cb_R_Cr )
		let row2 = simd_float3( B_Cb_R_Cr, G_Cr, B_Cr )
		let rgbToYuv = simd_float3x3(rows: [row0,row1,row2])
		return rgbToYuv
	}
	
	//	rgb = matrix * float3( luma, chroma-0.5)
	var yuvToRgb : simd_float3x3
	{
		return rgbToYuv.inverse
	}
}
	


public func CGImageToPixelBuffer(_ cg:CGImage) throws -> CVPixelBuffer
{
	try cg.withUnsafePixels 
	{ 
		cgImageBytes, width, height, rowStride, pixelFormat in
		
		//	allow use in metal
		let options : [CFString:Any] = 
		[	
			kCVPixelBufferMetalCompatibilityKey:true
		]
		
		let format = pixelFormat == kCVPixelFormatType_32RGBA ? kCVPixelFormatType_32BGRA : pixelFormat
		
		var pixelBuffer : CVPixelBuffer?
		let CreateStatus : OSStatus = CVPixelBufferCreate(kCFAllocatorDefault, width, height, format, options as CFDictionary, &pixelBuffer )
		if CreateStatus != 0
		{
			throw CGImageError("Failed to create \(width)x\(height)(\(format)) pixel buffer; \(GetVideoToolboxError(CreateStatus))")
		}
		guard let pixelBuffer else
		{
			throw CGImageError("Failed to create \(width)x\(height)(\(format)) pixel buffer; \(GetVideoToolboxError(CreateStatus)) (null)")
		}
		
		try pixelBuffer.LockMutablePixels
		{
			(bytes:UnsafeMutableBufferPointer<UInt8>) in
			
			//	expecting colour bytes & format to align
			//	once format is customisable, change the colour byte array above
			let destRaw = UnsafeMutableRawBufferPointer(bytes)
			let srcRaw = UnsafeRawBufferPointer(cgImageBytes)
			srcRaw.copyBytes(to: destRaw)
		}
		
		return pixelBuffer
	}
}

public extension CGImage
{
	var cvPixelBuffer : CVPixelBuffer
	{
		get throws
		{
			return try CGImageToPixelBuffer(self)
		}
	}
}


public extension CVPixelBuffer 
{
	var cgImage : CGImage 
	{
		get throws
		{
			return try PixelBufferToCGImage(self)
		}
	}
		
	var width : Int				{	CVPixelBufferGetWidth(self)	}
	var height : Int				{	CVPixelBufferGetHeight(self)	}
	var pixelFormat : OSType		{	CVPixelBufferGetPixelFormatType(self)	}
	var sizeBytes : Int				{	CVPixelBufferGetDataSize(self)	}
	
	var pixelFormatName : String 
	{
		let p = CVPixelBufferGetPixelFormatType(self)
		return CVPixelBufferGetPixelFormatName(p)
	}
	var metalPixelFormat : MTLPixelFormat	{	CVPixelFormatToMetalPixelFormat(self.pixelFormat)	}
	
	var planeCount : Int
	{
		if !CVPixelBufferIsPlanar(self)
		{
			return 1
		}
		return CVPixelBufferGetPlaneCount(self)
	}
	
	var yuvColourMatrixKey : String?
	{
		if #available(macOS 12.0, *) 
		{
			let attachmentsDict = CVBufferCopyAttachments(self,.shouldPropagate)
			let attachments = attachmentsDict as? [String:Any]	//	matrix values at least are keys. This may want to be Any
			
			//	value of this the name(key) of a colour matrix
			let colourMatrixName = attachments?[kCVImageBufferYCbCrMatrixKey as String] as? String
			return colourMatrixName
		} 
		else 
		{
			return nil
		}
	}
	
	var yuvColourMatrix : simd_float3x3?
	{
		guard let colourMatrix = self.yuvColourMatrixKey else
		{
			return nil
		}
		
		switch colourMatrix as CFString
		{
				/*
			case kCVImageBufferYCbCrMatrix_ITU_R_2020:
				return vImage_ARGBToYpCbCrMatrix.itu_R_601_4.float4x4
				
			case kCVImageBufferYCbCrMatrix_P3_D65:
				return simd_float4x4.identity
				*/
			case kCVImageBufferYCbCrMatrix_ITU_R_709_2:
				//	todo: cache these in code
				if #available(iOS 18.0,macOS 15.0, *) {
					return vImage_ARGBToYpCbCrMatrix.itu_R_709_2.yuvToRgb
				} else {
					return nil
				}
				
			case kCVImageBufferYCbCrMatrix_ITU_R_601_4:
				//	todo: cache these in code
				if #available(iOS 18.0,macOS 15.0, *) {
					return vImage_ARGBToYpCbCrMatrix.itu_R_601_4.yuvToRgb
				} else {
					//	float3(0.99999994, 0.99999994, 0.99999994), 
					//	float3(1.464084e-08, -0.34413624, 1.7719998), 
					//	float3(1.4019998, -0.71413624, 2.9597064e-08) 
					return nil
				}
				/*
			case kCVImageBufferYCbCrMatrix_SMPTE_240M_1995:
				return simd_float4x4.identity
				
			case kCVImageBufferYCbCrMatrix_DCI_P3:
				return simd_float4x4.identity
				*/
				
				//	throw here for existance of a key, but not found?
			default:
				return nil
		}
	}
	
	func ToJpeg(qualityPercent:Int=99) throws -> Data
	{
		let cgImage = try self.cgImage
		return try cgImage.ToJpeg(qualityPercent:qualityPercent)
	}
}

public extension CVPixelBuffer 
{
	
	func copy() throws -> CVPixelBuffer {
		precondition(CFGetTypeID(self) == CVPixelBufferGetTypeID(), "copy() cannot be called on a non-CVPixelBuffer")
		
		var _copy: CVPixelBuffer?
		
		let width = CVPixelBufferGetWidth(self)
		let height = CVPixelBufferGetHeight(self)
		let formatType = CVPixelBufferGetPixelFormatType(self)
		
		let attachments = 
		{
			if #available(macOS 12.0, *) 
			{
				return CVBufferCopyAttachments(self, .shouldPropagate)
			} 
			else 
			{
				return CVBufferGetAttachments(self, .shouldPropagate)
			}
		}()
		
		CVPixelBufferCreate(nil, width, height, formatType, attachments, &_copy)
		
		guard let copy = _copy else 
		{
			throw RuntimeError("Failed to copy cvpixel buffer")
		}
		
		CVPixelBufferLockBaseAddress(self, .readOnly)
		CVPixelBufferLockBaseAddress(copy, [])
		
		defer {
			CVPixelBufferUnlockBaseAddress(copy, [])
			CVPixelBufferUnlockBaseAddress(self, .readOnly)
		}
		
		let pixelBufferPlaneCount: Int = CVPixelBufferGetPlaneCount(self)
		
		
		if pixelBufferPlaneCount == 0 {
			let dest = CVPixelBufferGetBaseAddress(copy)
			let source = CVPixelBufferGetBaseAddress(self)
			let height = CVPixelBufferGetHeight(self)
			let bytesPerRowSrc = CVPixelBufferGetBytesPerRow(self)
			let bytesPerRowDest = CVPixelBufferGetBytesPerRow(copy)
			if bytesPerRowSrc == bytesPerRowDest {
				memcpy(dest, source, height * bytesPerRowSrc)
			}else {
				var startOfRowSrc = source
				var startOfRowDest = dest
				for _ in 0..<height {
					memcpy(startOfRowDest, startOfRowSrc, min(bytesPerRowSrc, bytesPerRowDest))
					startOfRowSrc = startOfRowSrc?.advanced(by: bytesPerRowSrc)
					startOfRowDest = startOfRowDest?.advanced(by: bytesPerRowDest)
				}
			}
			
		}else {
			for plane in 0 ..< pixelBufferPlaneCount {
				let dest        = CVPixelBufferGetBaseAddressOfPlane(copy, plane)
				let source      = CVPixelBufferGetBaseAddressOfPlane(self, plane)
				let height      = CVPixelBufferGetHeightOfPlane(self, plane)
				let bytesPerRowSrc = CVPixelBufferGetBytesPerRowOfPlane(self, plane)
				let bytesPerRowDest = CVPixelBufferGetBytesPerRowOfPlane(copy, plane)
				
				if bytesPerRowSrc == bytesPerRowDest {
					memcpy(dest, source, height * bytesPerRowSrc)
				}else {
					var startOfRowSrc = source
					var startOfRowDest = dest
					for _ in 0..<height {
						memcpy(startOfRowDest, startOfRowSrc, min(bytesPerRowSrc, bytesPerRowDest))
						startOfRowSrc = startOfRowSrc?.advanced(by: bytesPerRowSrc)
						startOfRowDest = startOfRowDest?.advanced(by: bytesPerRowDest)
					}
				}
			}
		}
		return copy
	}
}


extension CVPixelBuffer
{
	//	withUnsafeBytes style access
	public func LockPixels(_ onLockedPixels:@escaping (UnsafeRawBufferPointer)throws->Void) throws
	{
		CVPixelBufferLockBaseAddress( self, [])
		
		let PixelRawPointer : UnsafeMutableRawPointer? = CVPixelBufferGetBaseAddress(self)
		let PixelDataSize = CVPixelBufferGetDataSize(self)
		guard let PixelRawPointer else
		{
			CVPixelBufferUnlockBaseAddress(self, [])
			throw RuntimeError("Failed to get address of pixels in CVPixelBuffer")
		}
		
		let PixelRawBuffer = PixelRawPointer.bindMemory(to: UInt8.self, capacity: PixelDataSize)
		let PixelBufferPointer = UnsafeBufferPointer(start: PixelRawBuffer, count: PixelDataSize)
		
		try PixelBufferPointer.withUnsafeBytes
		{
			pixelsPtr in
			do
			{
				//	destData?.copyMemory(from: rgba8PixelsPtr, byteCount: rgba8Pixels.count)
				try onLockedPixels(pixelsPtr)
			}
			catch let error
			{
				CVPixelBufferUnlockBaseAddress(self, [])
				throw error
			}
		}
		CVPixelBufferUnlockBaseAddress(self, [])
	}
	
	public func LockMutablePixels(_ onLockedPixels:@escaping (UnsafeMutableBufferPointer<UInt8>)throws->Void) throws
	{
		CVPixelBufferLockBaseAddress( self, [])
		
		let PixelRawPointer : UnsafeMutableRawPointer? = CVPixelBufferGetBaseAddress(self)
		let PixelDataSize = CVPixelBufferGetDataSize(self)
		guard let PixelRawPointer else
		{
			CVPixelBufferUnlockBaseAddress(self, [])
			throw RuntimeError("Failed to get address of pixels in CVPixelBuffer")
		}
		
		let PixelRawBuffer = PixelRawPointer.bindMemory(to: UInt8.self, capacity: PixelDataSize)
		var PixelBufferPointer = UnsafeMutableBufferPointer(start: PixelRawBuffer, count: PixelDataSize)
		
		try PixelBufferPointer.withUnsafeMutableBufferPointer
		{
			pixelsPtr in
			do
			{
				//	destData?.copyMemory(from: rgba8PixelsPtr, byteCount: rgba8Pixels.count)
				try onLockedPixels(pixelsPtr)
			}
			catch let error
			{
				CVPixelBufferUnlockBaseAddress(self, [])
				throw error
			}
		}
		CVPixelBufferUnlockBaseAddress(self, [])
	}
	
	public func Resize(width:Int,height:Int,forceOutputFormat:OSType?=nil) throws -> CVPixelBuffer
	{
		let ciImage = CIImage(cvPixelBuffer: self)
		let sourceDimensions = ciImage.extent
		
		let scaleFilter = CIFilter.lanczosScaleTransform()
		scaleFilter.inputImage = ciImage
		
		//	aspectRatio = horizontal scaling factor
		//	so, scale to height, then squash width 
		scaleFilter.scale = Float(height) / Float(sourceDimensions.height)
		let newWidth = scaleFilter.scale * Float(sourceDimensions.width)
		scaleFilter.aspectRatio = Float(width) / Float(newWidth)
		
		guard let outputImage = scaleFilter.outputImage else 
		{
			throw RuntimeError("CIFilter scale failed to produce output image") 
		}
		
		let outputFormat = forceOutputFormat ?? self.pixelFormat
		
		// Create a new CVPixelBuffer
		var outputPixelBuffer : CVPixelBuffer?
		let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, outputFormat, nil, &outputPixelBuffer)
		
		if status != kCVReturnSuccess
		{
			throw RuntimeError("CVPixelBufferCreate failed to create buffer: \(CVGetErrorString(error:status))")
		}
		guard let buffer = outputPixelBuffer else
		{
			throw RuntimeError("CVPixelBufferCreate succeeded but produced null buffer")
		}
		
		//	Render the CIImage into the new CVPixelBuffer
		let context = CIContext()
		context.render(outputImage, to: buffer)
		
		return buffer
	}
}

public func CVPixelFormatToMetalPixelFormat(_ pixelFormat:OSType,planeIndex:Int=0) -> MTLPixelFormat
{
	switch pixelFormat
	{
		case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange:
			return (planeIndex == 0) ? MTLPixelFormat.r8Unorm : MTLPixelFormat.rg8Unorm
			
		case kCVPixelFormatType_32BGRA:
			return MTLPixelFormat.bgra8Unorm
			
		case kCVPixelFormatType_DepthFloat32:
			return MTLPixelFormat.r32Float
			
		case kCVPixelFormatType_OneComponent16Half:
			return MTLPixelFormat.r16Float

		case kCVPixelFormatType_DepthFloat16:
			return MTLPixelFormat.r16Float
			
		case kCVPixelFormatType_OneComponent32Float:
			return MTLPixelFormat.r32Float
			
		default:
			return MTLPixelFormat.rgba32Float
	}
}
