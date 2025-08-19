import CoreImage

public extension CIImage
{
	var cgImage : CGImage
	{
		get throws
		{
			let device = MTLCreateSystemDefaultDevice()
			return try self.GetCGImage(metalDevice: device)
		}
	}
	
	func GetCGImage(metalDevice:MTLDevice?,format:CIFormat?=nil) throws -> CGImage
	{
		let ciContext = metalDevice.map{ CIContext(mtlDevice:$0) } ?? CIContext()
		
		if let format
		{
			guard let cgImageFromCI = ciContext.createCGImage(self, from: self.extent, format: format, colorSpace: nil) else
			{
				throw CGImageError("Failed to create CGImge from CIContext")
			}
			return cgImageFromCI
		}
		
		guard let cgImageFromCI = ciContext.createCGImage(self, from: self.extent) else
		{
			throw CGImageError("Failed to create CGImge from CIContext")
		}
		return cgImageFromCI
	}	
}
