import SwiftUI
import VideoToolbox
import Accelerate

func GetVideoToolboxError(_ result:OSStatus) -> OSStatus
{
	return result
}

public func PixelBufferToSwiftImage(_ pixelBuffer:CVPixelBuffer) async throws -> Image
{
	let cg = try await PixelBufferToCGImage(pixelBuffer)
#if os(iOS)
	let uiimage = UIImage(cgImage:cg)
	return try Image(uiImage: uiimage )
#else
	//	zero = auto size
	let uiimage = NSImage(cgImage:cg, size:.zero)
	return Image(nsImage: uiimage)
#endif
}


public func PixelBufferToCGImage(_ pb:CVPixelBuffer) async throws -> CGImage
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
}

/*
extension CVPixelBuffer
{
	static public let black1x1 = try! Create1x1CVPixelBuffer(colour:CGColor.black)
}
*/
public func Create1x1CVPixelBuffer(colour:CGColor) throws -> CVPixelBuffer
{
	let colourComponents = colour.components ?? [1,0,0,1]
	let colourBytes = colourComponents.map{ UInt8($0 * 255.0) }
	let format = kCVPixelFormatType_32BGRA
	let width = 1
	let height = 1
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
	let options : CFDictionary? = nil
	var pixelBuffer : CVPixelBuffer?
	
	// if pxbuffer = nil, you will get status = -6661
	let CreateStatus : OSStatus = CVPixelBufferCreate(kCFAllocatorDefault, width, height, format, options, &pixelBuffer )
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

