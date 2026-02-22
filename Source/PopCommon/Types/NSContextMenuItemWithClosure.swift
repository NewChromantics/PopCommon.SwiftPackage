#if canImport(AppKit)
import AppKit
#endif

@available(macOS 11.0, *)
public extension NSMenu
{
	func addItem(_ item:NSMenuItem?)
	{
		if let item
		{
			self.addItem(item)
		}
	}
}

@available(macOS 11.0, *)
public class NSMenuItemWithClosure : NSMenuItem
{
	var closure : ()->Void
	
	public init(title: String, keyEquivalent: String="",checked:Bool=false,enabled:Bool=true,icon:String?=nil,closure:@escaping()->Void)
	{
		self.closure = closure
		super.init(title: title, action: #selector(onMenuItemSelected), keyEquivalent: keyEquivalent)
		self.target = self
		if let icon
		{
			self.image = NSImage(systemSymbolName:icon, accessibilityDescription: nil)
		}
		self.isEnabled = enabled
		if checked
		{
			self.state = .on
		}
	}
	
	required init(coder: NSCoder) 
	{
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func onMenuItemSelected(_sender: NSMenuItem) 
	{
		self.closure()
	}
}
