import SwiftUI


public enum Cursor
{
	case
	pointer,	//	default
	link
	/*
	 horizontalText,
	 verticalText,
	 rectSelection
	 grabIdle
	 grabActive
	 link
	 zoomIn
	 zoomOut
	 columnResize
	 rowResize
	 */
	
	public var nsCursor : NSCursor
	{
		switch self
		{
			case .link:
				return NSCursor.pointingHand
			case .pointer:
				return NSCursor.arrow
			default:
				return NSCursor.arrow
		}
	}
}


public extension View 
{
	//	polyfill for .pointerstyle (macos15+) which changes cursor upon hover
	//	gr: should be a ViewModifier?
	public func hoverCursor(_ style: Cursor?) -> some View
	{
		if #available(macOS 15.0, *) 
		{
			AnyView(
				self
					.pointerStyle(.link)
			)
		}
		else if let style
		{
			AnyView(
				self.onHover 
				{
					inside in
					if inside 
					{
						NSCursor.pointingHand.set()
					}
					else 
					{
						NSCursor.arrow.set()
					}
				}
			)
		}
		else
		{
			AnyView(self)
		}
	}

	 
}
