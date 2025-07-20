import SwiftUI
import VideoToolbox
import Accelerate


public struct CGImageError : LocalizedError
{
	let description: String
	
	public init(_ description: String) {
		self.description = description
	}
	
	public var errorDescription: String? {
		description
	}
}



extension CGImage
{
	public static func fromRgbBuffer(_ rgbBuffer:inout[UInt8],width:Int,height:Int) throws -> CGImage
	{
		var convert = 
		{
			(rgb:inout vImage_Buffer,rgba:inout vImage_Buffer) in
			let alphaBuffer : UnsafePointer<vImage_Buffer>? = nil
			let alpha = Pixel_8(255)
			let premultiply = false	//	true performs {r = (a * r + 127) / 255}
			let flags = vImage_Flags(kvImageDoNotTile)
			let error = vImageConvert_RGB888toRGBA8888( &rgb, alphaBuffer, alpha, &rgba, premultiply, flags )
			if error != kvImageNoError
			{
				throw CGImageError("Some RGB to RGBA error")
			}
		}
		
		
		//	need to convert to RGBA for coregraphics
		var rgbaBuffer = [UInt8](repeating: 0, count: width*height*4)
		try rgbBuffer.withUnsafeMutableBytes
		{
			rgbBufferPointer in 
			try rgbaBuffer.withUnsafeMutableBytes
			{
				rgbaBufferPointer in
				var rgbImage = vImage_Buffer( data:rgbBufferPointer.baseAddress!, height:vImagePixelCount(height), width:vImagePixelCount(width), rowBytes: 3*width )
				var rgbaImage = vImage_Buffer( data:rgbaBufferPointer.baseAddress!, height:vImagePixelCount(height), width:vImagePixelCount(width), rowBytes: 4*width )
				
				try convert( &rgbImage, &rgbaImage )
			}
		}
		
		
		let bytesPerPixel = 4
		let bytesPerRow = bytesPerPixel * width
		let bitsPerComponent = 8
		
		
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let alpha = CGImageAlphaInfo.premultipliedLast.rawValue
		
		let cgimage = try rgbaBuffer.withUnsafeMutableBytes
		{
			rgbaBufferPointer in
			guard let context = CGContext(data: rgbaBufferPointer.baseAddress!, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: alpha) else
			{
				throw CGImageError("Failed to create cg context")
			}
			
			guard let cgImage = context.makeImage() else
			{
				throw CGImageError("Failed to create cg image")
			}
			return cgImage
		}
		
		return cgimage
	}
}


func GetVideoToolboxError(_ result:OSStatus) -> OSStatus
{
	return result
}

public func PixelBufferToSwiftImage(_ pixelBuffer:CVPixelBuffer) throws -> Image
{
	let cg = try PixelBufferToCGImage(pixelBuffer)
#if canImport(UIKit)
	let uiimage = UIImage(cgImage:cg)
	return Image(uiImage: uiimage )
#else
	//	zero = auto size
	let uiimage = NSImage(cgImage:cg, size:.zero)
	return Image(nsImage: uiimage)
#endif
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
}

public func PixelBufferToCGImage(_ pb:CVPixelBuffer) throws -> CGImage
{
	var cgImage: CGImage?
	
	let InputWidth = CVPixelBufferGetWidth(pb)
	let InputHeight = CVPixelBufferGetHeight(pb)
	let InputFormatName = CVPixelBufferGetPixelFormatName(pixelBuffer:pb)
	let inputFormat = CVPixelBufferGetPixelFormatType(pb)
	
	//	ipad/ios18 can't auto convert kCVPixelFormatType_OneComponent32Float
	//	macos and iphone15 convert this into a red image
	if ( inputFormat == kCVPixelFormatType_OneComponent32Float )
	{
		/*	using the accellerate framework may be a nice built in solution here
		var vimagebuffer = vImage_Buffer()
		var rgbCGImgFormat : vImage_CGImageFormat = vImage_CGImageFormat(
			bitsPerComponent: 8,
			bitsPerPixel: 32,
			colorSpace: CGColorSpaceCreateDeviceRGB(),
			bitmapInfo: CGBitmapInfo(rawValue:kCGBitmapByteOrder32Host.rawValue/* | kCGImageAlphaNoneSkipFirst.*/)
		)!
		
		/*
		 func vImageBuffer_InitWithCVPixelBuffer(
		 _ buffer: UnsafeMutablePointer<vImage_Buffer>,
		 _ desiredFormat: UnsafeMutablePointer<vImage_CGImageFormat>,
		 _ cvPixelBuffer: CVPixelBuffer,
		 _ cvImageFormat: vImageCVImageFormat!,
		 _ backgroundColor: UnsafePointer<CGFloat>!,
		 _ flags: vImage_Flags
		 ) -> vImage_Error
		 */
		let backgroundColour : [CGFloat] = [1,1,1,1]
		//vImageCVImageFormatRef cvImgFormatRef;
		var cvImgFormatPtr : Unmanaged<vImageCVImageFormat> = vImageCVImageFormat_CreateWithCVPixelBuffer(pb)!
		var cvImgFormat : vImageCVImageFormat = cvImgFormatPtr.takeRetainedValue()
		let flags = vImage_Flags()
		let error = vImageBuffer_InitWithCVPixelBuffer( &vimagebuffer, &rgbCGImgFormat, pb, cvImgFormat, backgroundColour, flags )
		if ( error != 0 )
		{
			throw PopError("Failed to make vimage \(GetVideoToolboxError(OSStatus(error)))")
		}
		 */
		
		//	todo: use our own gpu image convertor
	}
	
	let Result = VTCreateCGImageFromCVPixelBuffer( pb, options:nil, imageOut:&cgImage)
	
	if ( Result != 0 || cgImage == nil )
	{
		//throw RuntimeError("VideoToolbox failed to create CGImage (\(InputWidth)x\(InputHeight)[\(InputFormatName)]; \(GetVideoToolboxError(Result))")
		throw RuntimeError("VideoToolbox failed to create CGImage (\(InputWidth)x\(InputHeight)[\(InputFormatName)]; \(Result))")
	}
	return cgImage!
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

/*
extension CVPixelBuffer
{
	static public let black1x1 = try! Create1x1CVPixelBuffer(colour:CGColor.black)
}
*/
public func Create1x1CVPixelBuffer(colour:CGColor) throws -> CVPixelBuffer
{
	return try CreateFilledCVPixelBuffer(colour: colour, width: 1, height: 1)
}

public func CreateFilledCVPixelBuffer(colour:CGColor,width:Int,height:Int) throws -> CVPixelBuffer
{
	let colourComponents = colour.components ?? [1,0,0,1]
	let colourBytes = colourComponents.map{ UInt8($0 * 255.0) }
	let format = kCVPixelFormatType_32BGRA
	/*
	 //let cfnumPointer = UnsafeMutablePointer<UnsafeRawPointer>.allocate(capacity: 1)
	 //let cfnum = CFNumberCreate(kCFAllocatorDefault, .intType, cfnumPointer)
	 //let keys: [CFString] = [kCVPixelBufferCGImageCompatibilityKey, kCVPixelBufferCGBitmapContextCompatibilityKey, kCVPixelBufferBytesPerRowAlignmentKey]
	 let values: [CFTypeRef] = [kCFBooleanTrue, kCFBooleanTrue, cfnum!]
	 let keysPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
	 let valuesPointer =  UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
	 keysPointer.initialize(to: keys)
	 valuesPointer.initialize(to: values)
	 let options = CFDictionaryCreate(kCFAllocatorDefault, keysPointer, valuesPointer, keys.count, nil, nil)
	 */
	var pixelBuffer : CVPixelBuffer?
	
	//	allow use in metal
	let options : [CFString:Any] = 
	[	
		kCVPixelBufferMetalCompatibilityKey:true
	]
	
	// if pxbuffer = nil, you will get status = -6661
	let CreateStatus : OSStatus = CVPixelBufferCreate(kCFAllocatorDefault, width, height, format, options as CFDictionary, &pixelBuffer )
	if CreateStatus != 0
	{
		throw RuntimeError("Failed to create \(width)x\(height)(\(format)) pixel buffer; \(GetVideoToolboxError(CreateStatus))")
	}
	guard let pixelBuffer else
	{
		throw RuntimeError("Failed to create \(width)x\(height)(\(format)) pixel buffer; \(GetVideoToolboxError(CreateStatus)) (null)")
	}
	
	try pixelBuffer.LockMutablePixels
	{
		(bytes:UnsafeMutableBufferPointer<UInt8>) in
		
		//	expecting colour bytes & format to align
		//	once format is customisable, change the colour byte array above
		for i in 0...bytes.count-1
		{
			bytes[i] = colourBytes[i%colourBytes.count]
		}
	}
	
	return pixelBuffer
}


//	use same Image(uiImage:) constructor on macos & ios
public extension Image
{
	init(cgImage:CGImage)
	{
#if canImport(UIKit)//ios
		self.init(uiImage:UIImage(cgImage: cgImage))
#else
		self.init(nsImage:NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height) ))
#endif
	}
	
	//	use same Image(uiImage:) constructor on macos & ios
#if os(macOS)
	init(uiImage:UIImage)
	{
		self.init(nsImage:uiImage)
	}
#endif
}

public extension UIImage
{
#if !canImport(UIKit)//ios
	//	mac doesnt have a single-arg cgimage constructor
	convenience init(cgImage:CGImage)
	{
		self.init(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
	}
#endif
}



extension CGImage
{
	/*
	public func resize(withSize targetSize: CGSize) -> CGImage?
	{
		let targetWidth = Int(targetSize.width)
		let targetHeight = Int(targetSize.height)
		guard let context = CGContext.ARGBBitmapContext(width:targetWidth, height:targetHeight, withAlpha: true) else
		{
			return nil
		}
		context.draw(self, in: CGRect(x:0, y:0, width:targetWidth, height:targetHeight))
		guard let outputImage = context.makeImage() else
		{
			return nil
		}
		let outIsArgb = outputImage.alphaInfo == .first || outputImage.alphaInfo == .premultipliedFirst
		return outputImage
	}
	
	public func resizeWithAccelerate(withSize targetSize: CGSize) -> CGImage?
	{
		let targetWidth = Int(targetSize.width)
		let targetHeight = Int(targetSize.height)
		guard let context = CGContext.ARGBBitmapContext(width:targetWidth, height:targetHeight, withAlpha: true) else
		{
			return nil
		}
		guard let contextData = context.data else
		{
			return nil
		}
		
		var src = try! vImage_Buffer(cgImage: self)
		var dst = vImage_Buffer(data: contextData, height: vImagePixelCount(context.height), width: vImagePixelCount(context.width), rowBytes: context.bytesPerRow)
		//let flags = vImage_Flags(kvImageHighQualityResampling)
		let flags = vImage_Flags()
		
		//	this seems to have a problem of messing up ARGB & RGBA, despite both being ARGB...
		vImageScale_ARGB8888(&src, &dst, nil, flags)
		
		guard let outputImage = context.makeImage() else
		{
			return nil
		}
		return outputImage
	}
	 
	
	//	Resizes the image to the given size maintaining its original aspect ratio.
	func resizeMaintainingAspectRatio(withSize targetSize: CGSize) -> CGImage
	{
		let newSize: CGSize
		let widthRatio = targetSize.width / CGFloat(self.width)
		let heightRatio = targetSize.height / CGFloat(self.height)
		if(widthRatio > heightRatio) {
			newSize = CGSize(width: floor(CGFloat(self.width) * widthRatio), height: floor(CGFloat(self.height) * widthRatio))
		} else {
			newSize = CGSize(width: floor(CGFloat(self.width) * heightRatio), height: floor(CGFloat(self.height) * heightRatio))
		}
		return resize(withSize: newSize)!
	}
	 */
}

public extension CGImage
{
	func withUnsafePixels<Result>(_ callback:(UnsafePointer<UInt8>,_ width:Int,_ height:Int,_ rowStride:Int,_ isArgb:Bool)throws->Result) throws -> Result
	{
		let imageCg = self
		let alphaFirst = imageCg.alphaInfo == .first || imageCg.alphaInfo == .premultipliedFirst
		let alphaLast = imageCg.alphaInfo == .last || imageCg.alphaInfo == .premultipliedLast
		let isArgb = alphaFirst
		let pixelFormat = imageCg.pixelFormatInfo
		let bitsPerPixel = imageCg.bitsPerPixel
		let bitsPerComponent = imageCg.bitsPerComponent
		let bytesPerPixel = bitsPerPixel / bitsPerComponent
		let bytesPerPixel2 = imageCg.bytesPerRow / width
		let rowStride = imageCg.bytesPerRow / bytesPerPixel	//	some images are padded!
		let channels = bytesPerPixel
		let pixelData = imageCg.dataProvider!.data
		let sourceData : UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
		
		return try callback( sourceData, width, height, rowStride, isArgb )
	}
	
	var formatName : String 
	{
		let bitsPerComponent = self.bitsPerComponent
		let bytesPerPixel = self.bitsPerPixel / bitsPerComponent
		let channels = bytesPerPixel
		
		if channels == 1 && self.alphaInfo == .alphaOnly
		{
			return "Alpha"
		}
		
		if channels == 1
		{
			return "Greyscale"
		}
		
		let alphaFirst = self.alphaInfo == .premultipliedFirst || self.alphaInfo == .first
		let alphaLast = self.alphaInfo == .premultipliedLast || self.alphaInfo == .last
		let noAlpha = self.alphaInfo == .none
		
		if alphaFirst && channels == 4
		{
			return "ARGB"
		}
		if alphaLast && channels == 4
		{
			return "RGBA"
		}
		
		return "\(channels)channel" + ( noAlpha ? "(no alpha)":"" )
	}
}
