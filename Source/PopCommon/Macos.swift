/*
	ios/macos polyfills to reduce the need for macros or platform specific code
 
	As a rule, we use UIxxxx for types rather than NSxxxx (make macos compatible with ios
	rather than the other way around)
*/
import SwiftUI

#if canImport(UIKit)//ios
#else
public typealias UIColor = NSColor
public typealias UIImage = NSImage
#endif





//	ios doesn't have a constructor for symbolName, it works via named:
//	macos has seperate constructors
#if canImport(UIKit)//ios
extension UIImage
{
	public convenience init?(symbolName:String,variableValue:CGFloat)
	{
		self.init(named:symbolName)
	}
}
#endif

