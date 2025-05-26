/*
	Math functions
*/
import CoreGraphics


//	get normalised value within these bounds
public func range(_ min:CGFloat,_ max:CGFloat,value:CGFloat) -> CGFloat
{
	return (value-min) / (max-min)
}


public func lerp(_ min:CGFloat,_ max:CGFloat,_ time:CGFloat) -> CGFloat
{
	return min + ( (max-min)*time )
}
