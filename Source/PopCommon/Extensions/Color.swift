import simd
import SwiftUI

@available(macOS 11.0, *)
public extension Color
{
	var rgba : simd_float4?
	{
		let uic = UIColor(self)
		return uic.cgColor.rgba
	}
}

public extension CGColor
{
	var rgba : simd_float4?	
	{
		guard let components = self.components, components.count > 0 else 
		{
			return nil
		}
		
		//	handle sub-3 component colours (monochrome)
		let r = Float(components[0])
		let a = Float(self.alpha)

		if components.count < 3
		{
			return simd_float4( r, r, r, a )
		}
		
		let g = Float(components[1])
		let b = Float(components[2])
		return simd_float4( r,g,b,a )
	}
	
	static func fromRgba(_ rgba:simd_float4) -> CGColor
	{
		return CGColor(
			red:	CGFloat(rgba.x),
			green:	CGFloat(rgba.y),
			blue:	CGFloat(rgba.z),
			alpha:	CGFloat(rgba.w)
		)
	}
}
