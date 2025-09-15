/*
	Math functions
*/
import CoreGraphics


//	get normalised value within these bounds
public func range(_ min:CGFloat,_ max:CGFloat,value:CGFloat) -> CGFloat
{
	return (value-min) / (max-min)
}

public func range(_ min:Float,_ max:Float,value:Float) -> Float
{
	return (value-min) / (max-min)
}

public func range01(_ min:Float,_ max:Float,value:Float) -> Float
{
	return clamp( range(min,max,value:value), min:0, max: 1 )
}

//	matching simd order!
public func clamp(_ x:Float,min:Float,max:Float) -> Float
{
	return Swift.max( min, Swift.min( x, max ) )
}

public func lerp(_ min:CGFloat,_ max:CGFloat,_ time:CGFloat) -> CGFloat
{
	return min + ( (max-min)*time )
}
