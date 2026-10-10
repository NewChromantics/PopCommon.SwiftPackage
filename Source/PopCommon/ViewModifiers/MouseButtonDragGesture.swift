/*
 
	SwiftUI's DragGesture only works for left mouse button on macos.
	This fills that gap.
*/ 

import SwiftUI
import AppKit


@available(macOS 26, *)
struct MouseButtonDragGesture<Space: CoordinateSpaceProtocol>: NSGestureRecognizerRepresentable {
	enum Button: Int { case left = 0x1, right = 0x2, middle = 0x4 }
	
	struct Value {
		var startLocation: CGPoint
		var location: CGPoint
		var translation: CGSize
	}
	
	var button: Button
	var minimumDistance: CGFloat
	var coordinateSpace: Space
	private var changedAction: ((Value) -> Void)?
	private var endedAction: ((Value) -> Void)?
	
	init(button: Button, minimumDistance: CGFloat = 10, coordinateSpace: Space) {
		self.button = button
		self.minimumDistance = minimumDistance
		self.coordinateSpace = coordinateSpace
	}
	
	func onChanged(_ action: @escaping (Value) -> Void) -> Self {
		var copy = self; copy.changedAction = action; return copy
	}
	
	func onEnded(_ action: @escaping (Value) -> Void) -> Self {
		var copy = self; copy.endedAction = action; return copy
	}
	
	final class Coordinator {
		var startLocation: CGPoint = .zero
		var active = false   // true once minimumDistance has been reached
	}
	
	func makeCoordinator(converter: NSGestureRecognizerRepresentableCoordinateSpaceConverter) -> Coordinator {
		Coordinator()
	}
	
	func makeNSGestureRecognizer(context: Context) -> NSPressGestureRecognizer {
		let r = NSPressGestureRecognizer()
		r.minimumPressDuration = 0
		r.allowableMovement = .greatestFiniteMagnitude
		r.buttonMask = button.rawValue
		return r
	}
	
	func updateNSGestureRecognizer(_ r: NSPressGestureRecognizer, context: Context) {
		r.buttonMask = button.rawValue
	}
	
	func handleNSGestureRecognizerAction(_ r: NSPressGestureRecognizer, context: Context) {
		let c = context.coordinator
		let location = context.converter.location(in: coordinateSpace)
		
		if r.state == .began {
			c.startLocation = location
			c.active = false
		}
		
		let value = Value(startLocation: c.startLocation,
						  location: location,
						  translation: CGSize(width: location.x - c.startLocation.x,
											  height: location.y - c.startLocation.y))
		
		switch r.state {
			case .began, .changed:
				if !c.active,
				   hypot(value.translation.width, value.translation.height) >= minimumDistance {
					c.active = true
				}
				if c.active { changedAction?(value) }
			case .ended, .cancelled, .failed:
				if c.active { endedAction?(value) }
				c.active = false
			default:
				break
		}
	}
}

@available(macOS 26, *)
extension MouseButtonDragGesture where Space == LocalCoordinateSpace {
	init(button: Button, minimumDistance: CGFloat = 10) {
		self.init(button: button, minimumDistance: minimumDistance, coordinateSpace: .local)
	}
}

@available(macOS 26, *)
#Preview
{
	@Previewable @State var colour : Color?
	@Previewable @State var position : CGPoint = .zero
	@Previewable @State var grabOffset : CGPoint?
	
	Rectangle()
		.fill(colour ?? .gray)
		.frame(width:50,height:50)
		.coordinateSpace(.named("rect"))
		.position(position)
		.gesture(
			DragGesture(minimumDistance: 0, coordinateSpace: .named("canvas"))
			.onChanged 
			{
				drag in
				grabOffset = grabOffset ?? CGPoint(x: drag.startLocation.x - position.x, y: drag.startLocation.y - position.y)
				colour = .yellow
				position.x = drag.location.x - grabOffset!.x
				position.y = drag.location.y - grabOffset!.y
			}
			.onEnded
					 {
				drag in
				colour = nil
				grabOffset = nil
			}
		)
		.gesture(
			MouseButtonDragGesture(button: .right,minimumDistance: 0, coordinateSpace: .named("canvas"))
				.onChanged 
			{
				drag in
				grabOffset = grabOffset ?? CGPoint(x: drag.startLocation.x - position.x, y: drag.startLocation.y - position.y)
				colour = .green
				position.x = drag.location.x - grabOffset!.x
				position.y = drag.location.y - grabOffset!.y
			}
				.onEnded
			{
				drag in
				colour = nil
				grabOffset = nil
			}
		)
		.gesture(
			MouseButtonDragGesture(button: .middle,minimumDistance: 0, coordinateSpace: .named("canvas"))
				.onChanged 
			{
				drag in
				grabOffset = grabOffset ?? CGPoint(x: drag.startLocation.x - position.x, y: drag.startLocation.y - position.y)
				colour = .blue
				position.x = drag.location.x - grabOffset!.x
				position.y = drag.location.y - grabOffset!.y
			}
				.onEnded
			{
				drag in
				colour = nil
				grabOffset = nil
			}
		)

	
}
