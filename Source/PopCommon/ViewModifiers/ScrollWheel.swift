import SwiftUI

#if os(macOS)
import AppKit

private struct ScrollWheelModifier: ViewModifier 
{
	let action: (CGPoint) -> Void
	@State private var monitor: Any?
	
	func body(content: Content) -> some View 
	{
		content
			.onAppear 
			{
				// SwiftUI has no scroll-wheel gesture, so listen for the AppKit event directly
				//	todo: 
				//let sensitivity: Float = event.hasPreciseScrollingDeltas ? 0.01 : 0.1
				monitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) 
				{
					event in
					action(CGPoint(x: event.scrollingDeltaX, y: event.scrollingDeltaY))
					return event
				}
			}
			.onDisappear {
				if let monitor { NSEvent.removeMonitor(monitor) }
				monitor = nil
			}
	}
}
#endif // os(macOS)

public extension View 
{
	@ViewBuilder
	func onScrollWheel(perform action: @escaping (CGPoint) -> Void) -> some View 
	{
#if os(macOS)
		modifier(ScrollWheelModifier(action: action))
#else
		self   // no scroll-wheel support on iOS yet
#endif
	}
}
