/*
	Math functions
*/
import CoreGraphics
import simd


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

//	get normalised value within these bounds
public func range(_ min:simd_float2,_ max:simd_float2,value:simd_float2) -> simd_float2
{
	return (value-min) / (max-min)
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

public func lerp(min:simd_float2,max:simd_float2,_ time:simd_float2) -> simd_float2
{
	return min + ( (max-min)*time )
}

public func lerp(min:simd_float3,max:simd_float3,_ time:Float) -> simd_float3
{
	return min + ( (max-min)*time )
}
