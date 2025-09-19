/*

	Int Rect type to compliment CGRect
 
*/

public struct Rect
{
	public struct ClipRegion : RawRepresentable
	{
		var rawValue: Int
		
		static let Inside = 0x0
		static let Above = 0x01
		static let Below = 0x02
		static let LeftOf =	0x04
		static let RightOf = 0x08
		
		var isInside : Bool		{	self.rawValue == Self.Inside	}
		var isOutside : Bool	{	!isInside	}
		var isAbove : Bool		{	( self.rawValue & Self.Above ) != 0	}
		var isBelow : Bool		{	( self.rawValue & Self.Below ) != 0	}
		var isLeft : Bool		{	( self.rawValue & Self.LeftOf ) != 0	}
		var isRight : Bool		{	( self.rawValue & Self.RightOf ) != 0	}
		
		public init(rawValue value:Int)
		{
			self.rawValue = value
		}
	}		
	
	var left : Int
	var top : Int
	var width : Int
	var height : Int
	var right : Int	{	left + width - 1 }
	var bottom : Int	{	top + height - 1 }
	var cgRect : CGRect	{	return CGRect(x: left, y: top, width: width, height: height)	}
	var size2 : simd_float2		{	simd_float2(Float(width),Float(height))	}
	var topLeft2 : simd_float2	{	simd_float2(Float(left),Float(top))	}
	
	public func GetOriginalCoords(_ rectCoords:CGPoint) -> CGPoint
	{
		let x = rectCoords.x + CGFloat(left)
		let y = rectCoords.y + CGFloat(top)
		return CGPoint(x: x, y: y)
	}
	
	//	move a point from a different size rect, to this rect
	public func TransformToRect(otherRectPos:CGPoint,otherRect:Rect) -> CGPoint
	{
		let u = (otherRectPos.x-CGFloat(otherRect.left)) / CGFloat(otherRect.width)
		let v = (otherRectPos.y-CGFloat(otherRect.top)) / CGFloat(otherRect.height)
		let x = (u * CGFloat(self.width))
		let y = (v * CGFloat(self.height))
		return CGPoint(x: x, y: y)
	}
	
	public func Normalise(_ rectCoord:CGPoint) -> CGPoint
	{
		let u = (rectCoord.x-CGFloat(left)) / CGFloat(width)
		let v = (rectCoord.y-CGFloat(top)) / CGFloat(height)
		return CGPoint(x:u,y:v)
	}
	
	public func PixelToUv(_ xy:simd_float2) -> simd_float2
	{
		let uv = (xy - topLeft2) / (size2)
		return uv
	}
	
	public func GetClipRegion(x:Int,y:Int) -> ClipRegion
	{
		var region = ClipRegion.Inside
		if x < left
		{
			region |= ClipRegion.LeftOf
		}
		else if x > right
		{
			region |= ClipRegion.RightOf
		}
		
		if y < top
		{
			region |= ClipRegion.Above
		}
		else if y > bottom
		{
			region |= ClipRegion.Below
		}
		return ClipRegion(rawValue:region)
	}
	
	//	returns nil if fully outside
	public func ClipLine(p1:SIMD2<Int>,p2:SIMD2<Int>) -> (SIMD2<Int>,SIMD2<Int>)?
	{
		let region1 = GetClipRegion(x:p1.x,y:p1.y)
		let region2 = GetClipRegion(x:p2.x,y:p2.y)
		if region1.isOutside && region2.isOutside
		{
			return nil
		}
		if region1.isInside && region1.isInside
		{
			return (p1,p2)
		}
		
		//	cohen sutherland
		var dx = Float(p2.x - p1.x)
		var dy = Float(p2.y - p1.y)
		
		//	todo: catch /0 
		let slopeY = dx / dy; // slope to use for possibly-vertical lines
		let slopeX = dy / dx; // slope to use for possibly-horizontal lines
		
		let top = Float(top)
		let left = Float(left)
		let right = Float(right)
		let bottom = Float(bottom)
		
		func clipPoint(_ point:inout simd_float2)
		{
			if point.y < top
			{
				point.x = point.x + slopeY * (top - point.y)
				point.y = top
			}
			
			if point.y > bottom
			{
				point.x = point.x + slopeY * (bottom - point.y)
				point.y = bottom
			}
			
			if point.x > right
			{
				point.x = right
				point.y = point.y + slopeX * (right - point.x)
			}
			
			if point.x < left
			{
				point.x = left
				point.y = point.y + slopeX * (left - point.x)
			}
		}
		
		var point1f = simd_float2(Float(p1.x),Float(p1.y))
		var point2f = simd_float2(Float(p2.x),Float(p2.y))
		clipPoint( &point1f )
		clipPoint( &point2f )
		
		//	todo: check int rounding here
		let out1 = SIMD2<Int>( Int(point1f.x), Int(point1f.y) )
		let out2 = SIMD2<Int>( Int(point2f.x), Int(point2f.y) )
		return (out1,out2)
	}
}
