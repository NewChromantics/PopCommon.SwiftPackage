#if canImport(UIKit)
import UIKit
#endif


//	https://stackoverflow.com/a/63954930
public func DeviceHasNotch() -> Bool
{
#if canImport(UIKit)
	guard #available(iOS 11.0, *), let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else 
	{
		return false 
	}
	
	if UIDevice.current.orientation.isPortrait 
	{
		return window.safeAreaInsets.top >= 44
	}
	else 
	{
		return window.safeAreaInsets.left > 0 || window.safeAreaInsets.right > 0
	}
#else	//	macos
	return false
#endif
}
