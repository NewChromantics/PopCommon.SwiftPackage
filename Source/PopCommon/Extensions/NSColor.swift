import Foundation
#if canImport(UIKit)
import UIKit
#endif
//	else using alias


#if canImport(UIKit)
extension UIColor
{
	var alphaComponent : CGFloat	{	cgColor.alpha	}
}
#endif

public extension UIColor
{
	func multiplyAlpha(_ alpha:CGFloat) -> UIColor
	{
		let alpha = self.alphaComponent * alpha
		return self.withAlphaComponent(alpha)
	}
	
}
