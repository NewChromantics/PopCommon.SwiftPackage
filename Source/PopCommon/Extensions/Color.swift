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
	
	var rgb : simd_float3?
	{
		let uic = UIColor(self)
		return uic.cgColor.rgb
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
	
	var rgb : simd_float3?	
	{
		guard let components = self.components, components.count > 0 else 
		{
			return nil
		}
		
		//	handle sub-3 component colours (monochrome)
		let r = Float(components[0])
		
		if components.count < 3
		{
			return simd_float3( r, r, r )
		}
		
		let g = Float(components[1])
		let b = Float(components[2])
		return simd_float3( r,g,b )
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
	
	static func fromRgb(_ rgb:simd_float3) -> CGColor
	{
		return CGColor(
			red:	CGFloat(rgb.x),
			green:	CGFloat(rgb.y),
			blue:	CGFloat(rgb.z),
			alpha:	CGFloat(1)
		)
	}
}
