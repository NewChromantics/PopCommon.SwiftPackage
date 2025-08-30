import SwiftUI


public extension View
{
	func hoverCursor() -> some View 
	{
		modifier(HoverCursorModifier())
	}
}

public struct HoverCursorModifier : ViewModifier
{
	@State var isHovering : Bool = false
	
	public init()
	{
	}
	
	public func body(content: Content) -> some View 
	{
		content
			.onHover(perform: OnHover)
	}
	
	func OnHover(_ nowHovering:Bool)
	{
		self.isHovering = nowHovering
		//print("is hovering: \(nowHovering)")
		DispatchQueue.main.async
		{
#if os(macOS)
			if (self.isHovering) 
			{
				NSCursor.pointingHand.push()
			}
			else 
			{
				NSCursor.pop()
			}
#endif
		}
	}
}


#Preview
{
	Rectangle()
		.fill(.red)
		.hoverCursor()
}

