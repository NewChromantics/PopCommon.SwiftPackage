import Foundation
#if canImport(UIKit)
import UIKit
#endif
//	else using alias


public extension UIColor
{
	func multiplyAlpha(_ alpha:CGFloat) -> UIColor
	{
		let alpha = self.alphaComponent * alpha
		return self.withAlphaComponent(alpha)
	}
}
