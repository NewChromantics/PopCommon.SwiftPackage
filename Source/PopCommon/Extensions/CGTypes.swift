/*
	Utilities for CoreGraphics types
*/
import CoreGraphics
import simd


func * (lhs: CGSize, rhs: CGSize) -> CGSize {
	.init(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
}

func * (lhs: CGPoint, rhs: CGSize) -> CGPoint {
	.init(x: lhs.x * rhs.width, y: lhs.y * rhs.height)
}

func - (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
	.init(x: lhs.x - rhs, y: lhs.y - rhs)
}

func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
	.init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func + (lhs: CGSize, rhs: CGSize) -> CGSize {
	.init(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}

func / (lhs: CGSize, rhs: CGSize) -> CGSize {
	.init(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
}

extension CGSize {
	var toPoint: CGPoint { .init(x: width, y: height) }
	var half: CGSize { .init(width: width/2, height: height/2) }
}


extension CGSize
{
	public var asCgPoint : CGPoint	{	CGPoint(x:self.width,y:self.height)	}
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
	var center : CGPoint
	{
		let x = self.origin.x + (self.width / 2.0)
		let y = self.origin.y + (self.height / 2.0)
		return CGPoint(x:x,y:y)	
	}
	
	var left : CGFloat	{	return self.origin.x	}
	var right : CGFloat	{	return self.origin.x + self.size.width	}
	var top : CGFloat	{	return self.origin.y	}
	var bottom : CGFloat	{	return self.origin.y + self.size.height	}
	var topLeft : CGPoint	{	return self.origin	}
	var bottomRight : CGPoint	{	return CGPoint(x:right,y:bottom)	}
	
	//	turn 0...1 inside this rect to parent space
	func expandNormalised(_ boundsPos:CGPoint) -> CGPoint
	{
		let x = lerp(self.minX,self.maxX, boundsPos.x)
		let y = lerp(self.minY,self.maxY, boundsPos.y)
		return CGPoint(x:x,y:y)
	}
	
	func GetUnnormalisedPoint(normalised:CGPoint) -> CGPoint
	{
		let x = self.left + (normalised.x * self.width)
		let y = self.top + (normalised.y * self.height)
		return CGPoint( x:x, y:y )
	}
	
	func GetNormalisedPoint(local:CGPoint) -> CGPoint
	{
		let x = range( self.left, self.right, value: local.x )
		let y = range( self.top, self.bottom, value: local.y )
		return CGPoint( x:x, y:y )
	}
	
	func GetUnnormalised(normalised:CGRect) -> CGRect
	{
		let topLeft = GetUnnormalisedPoint(normalised: normalised.topLeft )
		let bottomRight = GetUnnormalisedPoint(normalised: normalised.bottomRight )
		let width = bottomRight.x - topLeft.x
		let height = bottomRight.y - topLeft.y
		return CGRect( origin:topLeft, size:CGSize(width:width,height:height) )
	}
	
	func resizeToFit(parentSize:CGSize,fitSize:CGRect) -> CGRect
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
	
	static func +=(lhs: inout CGRect, rhs: CGPoint)
	{
		lhs.origin += rhs
	}
	
	static func -=(lhs: inout CGRect, rhs: CGPoint)
	{
		lhs.origin -= rhs
	}
	
	static func +(lhs: CGRect, rhs: CGPoint?) -> CGRect?
	{
		guard let rhs else
		{
			return nil
		}
		return lhs.offsetBy(dx: rhs.x, dy: rhs.y)
	}
	
}

public extension CGSize
{
	var simd_float2 : simd_float2
	{
		return simd.simd_float2(Float(self.width),Float(self.height))
	}
}
public extension CGPoint
{
	var simd_float2 : simd_float2
	{
		return simd.simd_float2(Float(self.x),Float(self.y))
	}
}
