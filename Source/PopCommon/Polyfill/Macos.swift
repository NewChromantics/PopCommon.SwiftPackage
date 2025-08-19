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


#if os(macOS)
import AppKit
#else
import AVFoundation
#endif

public func PlaySystemBeep()
{
#if os(macOS)
	NSSound.beep()
#else
	//	gr: these don't seem to play on macos, but the API is there
	//	https://stackoverflow.com/a/31126202/355753
	//	https://github.com/TUNER88/iOSSystemSoundsLibrary?tab=readme-ov-file#list-of-systemsoundids
	//let systemSoundID: SystemSoundID = 1016	//	tweet
	let systemSoundID : SystemSoundID = 1073	//	AudioToneError
	AudioServicesPlayAlertSoundWithCompletion(systemSoundID, nil )
#endif
}
