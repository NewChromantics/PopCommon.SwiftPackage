/*
	Utilities for CoreGraphics types
*/
import CoreGraphics
import simd


public extension CGAffineTransform
{
	var float4x4 : simd_float4x4
	{
		let row_a = simd_float4( Float(self.a), Float(self.b), 0, 0 )
		let row_b = simd_float4( Float(self.c), Float(self.d), 0, 0 )
		let row_c = simd_float4( 0, 0, 1, 0 )
		let row_d = simd_float4( Float(self.tx), Float(self.ty), 0, 1 )
		return simd_float4x4(columns: (row_a,row_b,row_c,row_d) )
	}
}


func * (lhs: CGSize, rhs: CGSize) -> CGSize {
	.init(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
}

func * (lhs: CGPoint, rhs: CGSize) -> CGPoint {
	.init(x: lhs.x * rhs.width, y: lhs.y * rhs.height)
}

func + (lhs: CGSize, rhs: CGSize) -> CGSize {
	.init(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}

func / (lhs: CGSize, rhs: CGSize) -> CGSize {
	.init(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
}

extension CGSize 
{
	var toPoint: CGPoint { .init(x: width, y: height) }
	var half: CGSize { .init(width: width/2, height: height/2) }
}


extension CGSize
{
	public var asCgPoint : CGPoint	{	CGPoint(x:self.width,y:self.height)	}
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



//	nice accessors
public extension CGRect
{
	//	these are no longer corrected and assume view.isFlipped
	//	where origin == topleft
	var top : CGFloat			{	self.minY	}
	var bottom : CGFloat		{	self.maxY	}
	var left : CGFloat			
	{
		get { self.minX }
		set { origin.x = newValue	}
	}
	var right : CGFloat
	{
		get	{	self.maxX	}
		set	{	size.width = newValue - minX	}
	}
	var middleLeft : CGPoint	{	CGPoint( x: left, y:midY )	}
	var middleRight : CGPoint	{	CGPoint( x: right, y:midY )	}
	var center : CGPoint		{	CGPoint(x: midX,y: midY)	}
	
	var topLeft : CGPoint		{	CGPoint( x: left, y:top )	}
	var topCenter : CGPoint		{	CGPoint( x: midX, y:top )	}
	var topRight : CGPoint		{	CGPoint( x: right, y:top )	}
	
	var bottomLeft : CGPoint	{	CGPoint( x: left, y:bottom )	}
	var bottomCenter : CGPoint	{	CGPoint( x: midX, y:bottom )	}
	var bottomRight : CGPoint	{	CGPoint( x: right, y:bottom )	}
	
	/*	gr: this keeps causing ambigious conflicts when importing coregraphics, giving up using it
	//	add a setter for these native accessors
	var width : CGFloat
	{
		get{	self.size.width	}
		set{	self.size.width = newValue	}
	}
	var height : CGFloat
	{
		get{	self.size.height	}
		set{	self.size.height = newValue	}
	}
	*/
}


//	operators
public extension CGRect
{	
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

//	nice inits
public extension CGRect
{
	init(_ x:CGFloat,_ y:CGFloat,width:CGFloat,height:CGFloat)
	{
		self.init( origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height))
	}
	
	init(center:CGPoint,width:CGFloat,height:CGFloat)
	{
		let x = center.x - (width/2)
		let y = center.y - (height/2)
		self.init( origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height))
	}
	
	init(accumulate rects:[CGRect])
	{
		if rects.count == 0
		{
			self.init()
		}
		else if rects.count == 1
		{
			self.init(origin: rects[0].origin, size: rects[0].size )
		}
		else
		{
			let points = rects.flatMap{ [$0.topLeft,$0.bottomRight] }
			self.init(accumulate:points)
		}
	}
	
	init(accumulate points:[CGPoint])
	{
		var minx = points.first?.x ?? CGFloat.infinity
		var maxx = points.first?.x ?? CGFloat.infinity
		var miny = points.first?.y ?? CGFloat.infinity
		var maxy = points.first?.y ?? CGFloat.infinity
		
		for point in points
		{
			minx = min( minx, point.x )
			miny = min( miny, point.y )
			maxx = max( maxx, point.x )
			maxy = max( maxy, point.y )
		}
		
		let width = maxx - minx
		let height = maxy - miny
		self.init(minx,miny,width:width,height: height)
	}
	
}




public extension CGRect
{
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
	
	
	
	
	
	func GetSubRect(_ chunkX:Int,_ chunkY:Int,chunksWide:Int,chunksHigh:Int) -> CGRect
	{
		let chunksWide = max(1,chunksWide)
		let chunksHigh = max(1,chunksHigh)
		var chunkRect = self
		chunkRect.size.width /= CGFloat(chunksWide)
		chunkRect.size.height /= CGFloat(chunksHigh)
		
		var subRect = chunkRect
		subRect.origin.x += CGFloat(chunkX) * chunkRect.width
		subRect.origin.y += CGFloat(chunkY) * chunkRect.height
		return subRect
	}
	
	func Split(chunksWide:Int,chunksHigh:Int) -> [CGRect]
	{
		let chunksWide = max(1,chunksWide)
		let chunksHigh = max(1,chunksHigh)
		var chunkRect = self
		chunkRect.size.width /= CGFloat(chunksWide)
		chunkRect.size.height /= CGFloat(chunksHigh)
		
		var chunkRects : [CGRect] = []
		for x in 0..<chunksWide
		{
			for y in 0..<chunksHigh
			{
				var subRect = chunkRect
				subRect.origin.x += CGFloat(x) * chunkRect.width
				subRect.origin.y += CGFloat(y) * chunkRect.height
				chunkRects.append(subRect)
			}
		}
		return chunkRects
	}
	
	
	//	get a sub-rect of a size, centered on/within this rect
	//	passing nil for dimension uses existing
	func GetCenteredRect(width:CGFloat?,height:CGFloat?=nil) -> CGRect
	{
		var subRect = self
		subRect.size.width = width ?? subRect.width
		subRect.size.height = height ?? subRect.height
		subRect.origin.x = self.midX - (subRect.width / 2.0)
		subRect.origin.y = self.midY - (subRect.height / 2.0)
		return subRect
	}
	
	func SubtractPosition(_ offset:CGPoint) -> CGRect
	{
		let x = self.origin.x - offset.x
		let y = self.origin.y - offset.y
		return CGRect(x, y, width: width, height: height)
	}
	
	func Move(_ offset:CGPoint) -> CGRect
	{
		let x = self.origin.x + offset.x
		let y = self.origin.y + offset.y
		return CGRect(x, y, width: width, height: height)
	}
	
	func WithLeftRight(_ left:CGFloat,_ right:CGFloat) -> CGRect
	{
		let width = right - left
		return CGRect(x:left, y:self.minY, width:width, height:self.height)
	}
	
	func contains(y:CGFloat) -> Bool
	{
		return y >= minY && y <= maxY
	}
	
	
	
	func cutLeft(cutPx:CGFloat) -> CGRect
	{
		let x = minX + cutPx
		let w = self.width - cutPx
		return CGRect(x, minY, width: w, height: self.height)
	}
	
	func cutRight(cutPx:CGFloat) -> CGRect
	{
		let w = self.width - cutPx
		return CGRect(minX, minY, width: w, height: self.height)
	}
	
	func leftSlice(cutPx:CGFloat) -> CGRect
	{
		return CGRect(minX, minY, width: cutPx, height: self.height)
	}
	
	func rightSlice(cutPx:CGFloat) -> CGRect
	{
		let x = self.maxX - cutPx
		return CGRect(x, minY, width: cutPx, height: self.height)
	}
	
	
	
	//	cut from origin rather than "Top"
	func cutOriginY(cutPx:CGFloat) -> CGRect
	{
		let y = origin.y - cutPx
		let h = self.height - cutPx
		return CGRect(minX, y, width: width, height: height)
	}
	
	//	slice a rect off self and return it
	mutating func popFromOriginY(cutPx:CGFloat) -> CGRect
	{
		//	cut this off
		let slice = CGRect(x:minX,y:minY,width: width,height: cutPx)
		
		self.origin.y += cutPx
		self.size.height -= cutPx
		return slice
	}
	
	mutating func popFromLeft(cutPx:CGFloat) -> CGRect
	{
		//	cut this off
		let slice = CGRect(x:minX,y:minY,width: cutPx,height: height)
		
		self.origin.x += cutPx
		self.size.width -= cutPx
		return slice
	}
	
	//	slice a rect off self and return it
	mutating func popFromTop(cutPx:CGFloat) -> CGRect
	{
		//	cut this off
		let slice = CGRect(x:minX,y:minY,width: width,height: cutPx)
		
		self.origin.y += cutPx
		self.size.height -= cutPx
		return slice
	}
	
	//	slice a rect off self and return it
	mutating func popFromBottom(cutPx:CGFloat) -> CGRect
	{
		//	cut this off
		let slice = CGRect(x:minX,y:bottom-cutPx,width: width,height: cutPx)
		self.size.height -= cutPx
		return slice
	}
	
	mutating func restrainToParent(_ parent:CGRect)
	{
		/*
		 self.origin.x = max( self.origin.x, parent.origin.x )
		 self.origin.y = max( self.origin.y, parent.origin.y )
		 let overflowx = max( 0, self.right - parent.right )
		 let overflowy = max( 0, self.top - parent.top )
		 self.size.width -= overflowx
		 self.size.height -= overflowy*/
	}
	
	func inside(parent:CGRect) -> Bool
	{
		if minX < parent.minX
		{
			return false
		}
		if minY < parent.minY
		{
			return false
		}
		if maxX > parent.maxX
		{
			return false
		}
		if maxY > parent.maxY
		{
			return false
		}
		return true
	}
}



public extension CGSize
{
	var simd_float2 : simd_float2
	{
		return simd.simd_float2(Float(self.width),Float(self.height))
	}
}
