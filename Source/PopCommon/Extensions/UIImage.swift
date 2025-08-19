import SwiftUI

//internal typealias UIImage = NSImage


#if canImport(AppKit)//macos
//	accessor with no arugments missing in macos
public extension UIImage
{
	var cgImage : CGImage?
	{
		return self.cgImage(forProposedRect: nil, context: nil, hints: nil)
	}
}
#endif

#if canImport(UIKit)
public extension UIImage
{
	//	not present in ios
	convenience init?(contentsOf:URL)
	{
		self.init(contentsOfFile: contentsOf.absoluteString)
	}
}
#endif

public struct UIImageError : LocalizedError
{
	let description: String
	
	public init(_ description: String) {
		self.description = description
	}
	
	public var errorDescription: String? {
		description
	}
}




extension UIImage 
{
	/*
	 func resize(withSize targetSize: CGSize) -> UIImage 
	 {
	 //	this accellerate-based resize is a little faster, but still CPU based
	 let smallImage = self.cgImage!.resize(withSize: targetSize)
	 return UIImage(cgImage: smallImage!)
	 
	 let targetRect = CGRect( origin: .zero, size: targetSize )
	 
	 #if canImport(UIKit)
	 //	https://stackoverflow.com/a/72353628/355753
	 let format = UIGraphicsImageRendererFormat(for: UITraitCollection(displayScale: 1))
	 let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
	 let img = renderer.image 
	 { 
	 ctx in
	 draw(in:targetRect)
	 }
	 return img
	 #else
	 let newImage = UIImage(size: targetSize)
	 newImage.lockFocus()
	 draw(in: CGRect(origin: .zero, size: targetSize), from: CGRect(origin: .zero, size: size), operation: .sourceOver, fraction: 1.0)
	 newImage.unlockFocus()
	 return newImage
	 #endif
	 }
	 
	 //	Resizes the image to the given size maintaining its original aspect ratio.
	 func resizeMaintainingAspectRatio(withSize targetSize: CGSize) -> UIImage
	 {
	 let newSize: CGSize
	 let widthRatio = targetSize.width / size.width
	 let heightRatio = targetSize.height / size.height
	 if(widthRatio > heightRatio) {
	 newSize = CGSize(width: floor(size.width * widthRatio), height: floor(size.height * widthRatio))
	 } else {
	 newSize = CGSize(width: floor(size.width * heightRatio), height: floor(size.height * heightRatio))
	 }
	 return resize(withSize: newSize)
	 }
	 */
}


public extension UIImage
{
	func withUnsafePixels<Result>(_ callback:(UnsafeBufferPointer<UInt8>,_ width:Int,_ height:Int,_ rowStride:Int,_ pixelformat:OSType)throws->Result) throws -> Result
	{
		guard let cgImage = self.cgImage else
		{
			throw UIImageError("Failed to get cgimage from NSImage")
		}
		return try cgImage.withUnsafePixels(callback)
	}
}
