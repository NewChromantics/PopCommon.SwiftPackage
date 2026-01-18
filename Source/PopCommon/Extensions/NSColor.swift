import Foundation


public extension UIColor
{
	func multiplyAlpha(_ alpha:CGFloat) -> UIColor
	{
		let alpha = self.alphaComponent * alpha
		return self.withAlphaComponent(alpha)
	}
}
