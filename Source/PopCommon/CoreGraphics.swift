/*
	Utilities for CoreGraphics types
*/
import CoreGraphics


extension CGSize
{
	public var asCgPoint : CGPoint	{	CGPoint(x:self.width,y:self.height)	}
}

extension CGPoint
{
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
}



public func -(lhs: CGRect?, rhs: CGPoint?) -> CGRect?
{
	guard let rhs else
	{
		return nil
	}
	guard let lhs else
	{
		return nil
	}
	return lhs.offsetBy(dx: -rhs.x, dy: -rhs.y)
}



public extension CGRect
{
	//	turn 0.1 inside this rect to parent space
	func expandNormalised(_ boundsPos:CGPoint) -> CGPoint
	{
		let x = lerp(self.minX,self.maxX, boundsPos.x)
		let y = lerp(self.minY,self.maxY, boundsPos.y)
		return CGPoint(x:x,y:y)
	}
	
	public var center : CGPoint
	{
		let x = self.origin.x + (self.width / 2.0)
		let y = self.origin.y + (self.height / 2.0)
		return CGPoint(x:x,y:y)	
	}
	
	public var left : CGFloat	{	return self.origin.x	}
	public var right : CGFloat	{	return self.origin.x + self.size.width	}
	public var top : CGFloat	{	return self.origin.y	}
	public var bottom : CGFloat	{	return self.origin.y + self.size.height	}
	
	public func GetUnnormalisedPoint(normalised:CGPoint) -> CGPoint
	{
		let x = self.left + (normalised.x * self.width)
		let y = self.top + (normalised.y * self.height)
		return CGPoint( x:x, y:y )
	}
	
	public func resizeToFit(parentSize:CGSize,fitSize:CGRect) -> CGRect
	{
		let parentRect = CGRect( origin: CGPoint(x:0,y:0), size: parentSize )
		
		//	normalise self
		let left = range( parentRect.left, parentRect.right, value: self.left )
		let right = range( parentRect.left, parentRect.right, value: self.right )
		let top = range( parentRect.top, parentRect.bottom, value: self.top )
		let bottom = range( parentRect.top, parentRect.bottom, value: self.bottom )
		
		//	position inside new parent
		let NewTopLeft = fitSize.GetUnnormalisedPoint( normalised:CGPoint(x:left,y:top) )
		let NewBottomRight = fitSize.GetUnnormalisedPoint( normalised:CGPoint(x:right,y:bottom) )
		
		let width = NewBottomRight.x - NewTopLeft.x
		let height = NewBottomRight.y - NewTopLeft.y
		return CGRect( origin:NewTopLeft, size:CGSize(width:width,height:height) )
	}
	
	public static func +=(lhs: inout CGRect, rhs: CGPoint)
	{
		lhs.origin += rhs
	}
	
	public static func -=(lhs: inout CGRect, rhs: CGPoint)
	{
		lhs.origin -= rhs
	}
	
	public static func +(lhs: CGRect, rhs: CGPoint?) -> CGRect?
	{
		guard let rhs else
		{
			return nil
		}
		return lhs.offsetBy(dx: rhs.x, dy: rhs.y)
	}
	
}
