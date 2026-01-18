/*
	Utilities for CoreGraphics types
*/
import CoreGraphics
import simd

public extension CGPoint
{
	var simd_float2 : simd_float2
	{
		return simd.simd_float2(Float(self.x),Float(self.y))
	}
}


extension CGPoint
{
	public var asCgSize : CGSize	{	CGSize(width:self.x,height:self.y)	}

	public static func +=(lhs: inout CGPoint, rhs: CGPoint)
	{
		lhs.x += rhs.x
		lhs.y += rhs.y
	}
	
	public static func -=(lhs: inout CGPoint, rhs: CGPoint)
	{
		lhs.x -= rhs.x
		lhs.y -= rhs.y
	}
	
	public static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint
	{
		return CGPoint( x:lhs.x+rhs.x, y:lhs.y+rhs.y )
	}
	
	public static func -(_ left: CGPoint, _ right: CGPoint)->CGPoint
	{
		return .init(x: left.x-right.x, y: left.y-right.y)
	}

}

