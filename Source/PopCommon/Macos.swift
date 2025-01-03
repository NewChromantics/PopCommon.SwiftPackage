/*
	ios/macos polyfills to reduce the need for macros or platform specific code
 
	As a rule, we use UIxxxx for types rather than NSxxxx (make macos compatible with ios
	rather than the other way around)
*/
import SwiftUI

#if canImport(UIKit)//ios
#else
typealias UIImage = NSImage
#endif


#if canImport(UIKit)//ios
#else

//	use same Image(uiImage:) constructor on macos & ios
extension Image
{
	init(uiImage:UIImage)
	{
		self.init(nsImage:uiImage)
	}
}
#endif


