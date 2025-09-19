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
	public static func fromRgbBuffer(_ rgbBuffer:[UInt8],width:Int,height:Int) throws -> CGImage
	{
		var rgbBuffer = rgbBuffer
		return try fromRgbBuffer(&rgbBuffer, width: width, height: height)
	}
		
	public static func fromRgbBuffer(_ rgbBuffer:inout[UInt8],width:Int,height:Int) throws -> CGImage
	{
		let convert = 
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
	
	public static func fromRgbaBuffer(_ rgbaBuffer:[UInt8],width:Int,height:Int) throws -> CGImage
	{
		var rgbaBuffer = rgbaBuffer
		return try fromRgbaBuffer(&rgbaBuffer, width: width, height: height)
	}
	
	public static func fromRgbaBuffer(_ rgbaBuffer:inout[UInt8],width:Int,height:Int) throws -> CGImage
	{
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
	
	
	public static func fromAlphaBuffer(_ alphaBuffer:inout[UInt8],width:Int,height:Int) throws -> CGImage
	{
		let bytesPerPixel = 1
		let bytesPerRow = bytesPerPixel * width
		let bitsPerComponent = 8
		
		
		let colorSpace = CGColorSpaceCreateDeviceGray()
		//let colorSpace : CGColorSpace? = nil
		let alpha = CGImageAlphaInfo.alphaOnly.rawValue
		
		let cgimage = try alphaBuffer.withUnsafeMutableBytes
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


public func PixelBufferToCGImage(_ pb:CVPixelBuffer,useCoreImage:Bool=false) throws -> CGImage
{
	//	alternative
	if useCoreImage
	{
		let ci = CIImage(cvPixelBuffer: pb)
		return try ci.cgImage
	}
	
	
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
		//	alternative
		do
		{
			let ci = CIImage(cvPixelBuffer: pb)
			return try ci.cgImage
		}
		catch
		{
			print("Backup PixelBuffer->CIImage failed \(error.localizedDescription)")
		}		

		//	kVTParameterErr -12902
		//throw RuntimeError("VideoToolbox failed to create CGImage (\(InputWidth)x\(InputHeight)[\(InputFormatName)]; \(GetVideoToolboxError(Result))")
		throw RuntimeError("VideoToolbox failed to create CGImage (\(InputWidth)x\(InputHeight)[\(InputFormatName)]; \(Result))")
	}
	return cgImage!
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
		let bytesPerComponent = 1
		let bytesPerRow = targetWidth * 4 * bytesPerComponent
		let colour = CGColorSpaceCreateDeviceRGB()
		
		let bitmapInfo = CGImageAlphaInfo.last.rawValue
		let context = CGContext.init(data: nil, width: targetWidth, height: targetHeight, bitsPerComponent: 8*bytesPerComponent, bytesPerRow: bytesPerRow, space: colour, bitmapInfo: bitmapInfo)
		/*
		guard let context = CGContext.ARGBBitmapContext(width:targetWidth, height:targetHeight, withAlpha: true) else
		{
			return nil
		}*/
		context.draw(self, in: CGRect(x:0, y:0, width:targetWidth, height:targetHeight))
		guard let outputImage = context.makeImage() else
		{
			return nil
		}
		let outIsArgb = outputImage.alphaInfo == .first || outputImage.alphaInfo == .premultipliedFirst
		return outputImage
	}*/
	/*
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
	var dimensions32 : (UInt32,UInt32)	{	(UInt32(self.width),UInt32(self.height))	}
	var sizeBytes : Int		{	self.bytesPerRow * self.height	}
	
	
	func withUnsafePixels<Result>(_ callback:(UnsafeBufferPointer<UInt8>,_ width:Int,_ height:Int,_ rowStride:Int,_ pixelFormat:OSType)throws->Result) throws -> Result
	{
		let imageCg = self
		//let pixelFormatInfo = imageCg.pixelFormatInfo
		let bitsPerPixel = imageCg.bitsPerPixel
		let bitsPerComponent = imageCg.bitsPerComponent
		let bytesPerPixel = bitsPerPixel / bitsPerComponent
		//let bytesPerPixel2 = imageCg.bytesPerRow / width
		let rowStride = imageCg.bytesPerRow / bytesPerPixel	//	some images are padded!
		let channels = bytesPerPixel
		guard let dataProvider = imageCg.dataProvider else
		{
			throw CGImageError("Failed to get data provider for image")
		}
		guard let pixelData = dataProvider.data else
		{
			throw CGImageError("Failed to get data provider.data for image")
		}			
		let sourceData : UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
		let sourceDataSize = CFDataGetLength(pixelData)
		let pixelFormat = try GetPixelFormat()

		//	expect alignment
		if ( channels * rowStride * height != sourceDataSize )
		{
			throw CGImageError("Image data vs dimensions misalignment")
		}
		
		let sourceBuffer = UnsafeBufferPointer<UInt8>( start: sourceData, count: sourceDataSize )
		return try callback( sourceBuffer, width, height, rowStride, pixelFormat )
	}
	
	//	duplicate of above with async
	func withUnsafePixels<Result>(_ callback:(UnsafeBufferPointer<UInt8>,_ width:Int,_ height:Int,_ rowStride:Int,_ pixelFormat:OSType)async throws->Result) async throws -> Result
	{
		let imageCg = self
		//let pixelFormatInfo = imageCg.pixelFormatInfo
		let bitsPerPixel = imageCg.bitsPerPixel
		let bitsPerComponent = imageCg.bitsPerComponent
		let bytesPerPixel = bitsPerPixel / bitsPerComponent
		//let bytesPerPixel2 = imageCg.bytesPerRow / width
		let rowStride = imageCg.bytesPerRow / bytesPerPixel	//	some images are padded!
		let channels = bytesPerPixel
		guard let dataProvider = imageCg.dataProvider else
		{
			throw CGImageError("Failed to get data provider for image")
		}
		guard let pixelData = dataProvider.data else
		{
			throw CGImageError("Failed to get data provider.data for image")
		}			
		let sourceData : UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
		let sourceDataSize = CFDataGetLength(pixelData)
		let pixelFormat = try GetPixelFormat()
		
		//	expect alignment
		if ( channels * rowStride * height != sourceDataSize )
		{
			throw CGImageError("Image data vs dimensions misalignment")
		}
		
		let sourceBuffer = UnsafeBufferPointer<UInt8>( start: sourceData, count: sourceDataSize )
		return try await callback( sourceBuffer, width, height, rowStride, pixelFormat )
	}
	
	
	//	calculate pixelformat
	//	using CVPixelPformat to match CVPixelBuffer
	func GetPixelFormat() throws -> OSType
	{
		//let pixelFormatInfo = self.pixelFormatInfo
		
		let bitsPerComponent = self.bitsPerComponent
		let bitsPerPixel = self.bitsPerPixel
		let bytesPerPixel = bitsPerPixel / bitsPerComponent
		let channels = bytesPerPixel
		let isFloatFormat = self.bitmapInfo.contains(.floatComponents)
		
		//	skip first & skip last luckily are filled with 255
		let alphaFirst = self.alphaInfo == .premultipliedFirst || self.alphaInfo == .first || self.alphaInfo == .noneSkipFirst
		let alphaLast = self.alphaInfo == .premultipliedLast || self.alphaInfo == .last || self.alphaInfo == .noneSkipLast
		let noAlpha = self.alphaInfo == .none
		
		if channels == 1 && bitsPerComponent == 16 && isFloatFormat
		{
			return kCVPixelFormatType_OneComponent16Half
		}
		if channels == 4 && bitsPerComponent == 16 && isFloatFormat
		{
			return kCVPixelFormatType_64RGBAHalf
		}
		
		if channels == 1 && bitsPerComponent == 32 && isFloatFormat
		{
			return kCVPixelFormatType_OneComponent32Float
		}
		
		if channels == 2 && bitsPerComponent == 32 && isFloatFormat
		{
			return kCVPixelFormatType_OneComponent32Float
		}
		
		if bitsPerComponent == 8
		{
			if channels == 1 && self.alphaInfo == .alphaOnly
			{
				//	alpha
				return kCVPixelFormatType_OneComponent8
			}
			
			if channels == 1
			{
				return kCVPixelFormatType_OneComponent8
			}
			
			if channels == 3
			{
				//	gr: seems to always be BGR
				return kCVPixelFormatType_24BGR
			}
			
			if alphaFirst && channels == 4
			{
				//	check this is RGB not BGR
				return kCVPixelFormatType_32ARGB
			}
			if alphaLast && channels == 4
			{
				//	check this is RGB not BGR
				return kCVPixelFormatType_32RGBA
			}
		}
		
		throw CGImageError("Unhandled format \(channels)channel" + ( noAlpha ? "(no alpha)":"" ) + " float=\(isFloatFormat)" )
	}
		
	var pixelFormat : OSType	
	{
		do
		{
			return try GetPixelFormat()
		}
		catch
		{
			print("pixel format error \(error.localizedDescription)")
			return 0
		}
	}
	
	var pixelFormatName : String	{	CVPixelBufferGetPixelFormatName(self.pixelFormat)	}
	var metalPixelFormat : MTLPixelFormat	{	CVPixelFormatToMetalPixelFormat(self.pixelFormat)	}
	
	func copy() throws -> CGImage 
	{
		guard let copy = self.copy() else
		{
			throw CGImageError("Failed to make copy")
		}
		return copy
	}
	
	func ToJpeg(qualityPercent:Int=99) throws -> Data
	{
		let cgImage = self
		
		let data = NSMutableData()
		let properties: [CFString: Any] = 
		[
			kCGImageDestinationLossyCompressionQuality: Float(qualityPercent)/100.0
		]
		//	macos11+
		//let jpegUniveralType = UTType.jpeg.identifier
		let jpegUniveralType = "public.jpeg"
		guard let destination = CGImageDestinationCreateWithData(data, jpegUniveralType as CFString, 1, properties as CFDictionary) else
		{
			throw RuntimeError("Could not create jpeg destination")
		}
		
		CGImageDestinationAddImage(destination, cgImage, properties as CFDictionary)
		
		if !CGImageDestinationFinalize(destination) 
		{
			throw RuntimeError("failed to finalise jpeg destination")
		}
		
		return data as Data
	}
}


public extension CGImage
{
	static func Allocate(width:Int,height:Int,channels:Int) throws -> CGImage
	{
		let colourSpace = try {
			switch channels
			{
				case 1:	CGColorSpaceCreateDeviceGray()
				case 3: CGColorSpaceCreateDeviceRGB()
				default: throw CGImageError("Dont know how to make CGImage with \(channels) channels")
			}
		}()
		
		let bitmapInfo = CGImageAlphaInfo.none.rawValue | CGBitmapInfo.floatComponents.rawValue
		
		let bytesPerComponent = channels
		let bytesPerRow = width * bytesPerComponent
		let ptr : UnsafeMutableRawPointer? = nil
		let context = CGContext(data: ptr,//UnsafeMutableRawPointer(mutating: ptr.baseAddress!),
								width: width,
								height: height,
								bitsPerComponent: bytesPerComponent*8,
								bytesPerRow: bytesPerRow,
								space: colourSpace,
								bitmapInfo: bitmapInfo)
		guard let context else
		{
			throw CGImageError("Failed to make context")
		}
		guard let image = context.makeImage() else
		{
			throw CGImageError("Failed to make image from context")
		}
		return image
	}

	static func FromBytes(width:Int,bytes:inout [Float]) throws -> CGImage
	{
		let height = bytes.count / width
		let colourSpace = CGColorSpaceCreateDeviceGray()
		
		let bitmapInfo = CGImageAlphaInfo.none.rawValue | CGBitmapInfo.floatComponents.rawValue

		return try bytes.withUnsafeMutableBytes 
		{
			buffer in
			let bytesPerComponent = 4
			let bytesPerRow = width * bytesPerComponent
			let ptr = buffer.baseAddress 
			let context = CGContext(data: ptr,//UnsafeMutableRawPointer(mutating: ptr.baseAddress!),
									width: width,
									height: height,
									bitsPerComponent: bytesPerComponent*8,
									bytesPerRow: bytesPerRow,
									space: colourSpace,
									bitmapInfo: bitmapInfo)
			guard let context else
			{
				throw CGImageError("Failed to make context")
			}
			guard let image = context.makeImage() else
			{
				throw CGImageError("Failed to make image from context")
			}
			return image
		}
	}
}
