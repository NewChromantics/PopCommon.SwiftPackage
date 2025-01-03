/*
	Math functions
*/
import CoreGraphics


//	get normalised value within these bounds
public func range(_ min:CGFloat,_ max:CGFloat,value:CGFloat) -> CGFloat
{
	return (value-min) / (max-min)
}

