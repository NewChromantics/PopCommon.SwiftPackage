import SwiftUI

//	allow slider (anything) to bind an int to a float binding
//	https://stackoverflow.com/questions/65736518/how-do-i-create-a-slider-in-swiftui-bound-to-an-int-type-property
public extension Binding 
{
	static func convert<TInt, TFloat>(_ intBinding: Binding<TInt>) -> Binding<TFloat>
	where TInt:   BinaryInteger,
		  TFloat: BinaryFloatingPoint{
			  
			  Binding<TFloat> (
				get: { TFloat(intBinding.wrappedValue) },
				set: { intBinding.wrappedValue = TInt($0) }
			  )
		  }
	
	static func convert<TFloat, TInt>(_ floatBinding: Binding<TFloat>) -> Binding<TInt>
	where TFloat: BinaryFloatingPoint,
		  TInt:   BinaryInteger {
			  
			  Binding<TInt> (
				get: { TInt(floatBinding.wrappedValue) },
				set: { floatBinding.wrappedValue = TFloat($0) }
			  )
		  }
}
