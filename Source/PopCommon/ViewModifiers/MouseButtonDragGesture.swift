/*
 
	SwiftUI's DragGesture only works for left mouse button on macos.
	This fills that gap.
 
 
	To make this work on UIKit need to support other mouse buttons via Info.plist
	UIApplicationSupportsIndirectInputEvents = YES
*/ 
import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

@available(macOS 26, iOS 18, *)
public struct MouseButtonDragGesture<Space: CoordinateSpaceProtocol> 
{
	public enum Button { case left, right, middle }
	
	public struct Value 
	{
		public var startLocation: CGPoint
		public var localStartLocation: CGPoint
		public var location: CGPoint
		public var translation: CGSize
		
		public init(startLocation: CGPoint, localStartLocation: CGPoint, location: CGPoint, translation: CGSize) 
		{
			self.startLocation = startLocation
			self.localStartLocation = localStartLocation
			self.location = location
			self.translation = translation
		}
	}
	
	var button: Button
	var minimumDistance: CGFloat
	var coordinateSpace: Space
	private var changedAction: ((Value) -> Void)?
	private var endedAction: ((Value) -> Void)?
	
	public init(button: Button, minimumDistance: CGFloat = 10, coordinateSpace: Space) 
	{
		self.button = button
		self.minimumDistance = minimumDistance
		self.coordinateSpace = coordinateSpace
	}
	
	public func onChanged(_ action: @escaping (Value) -> Void) -> Self {
		var copy = self; copy.changedAction = action; return copy
	}
	
	public func onEnded(_ action: @escaping (Value) -> Void) -> Self {
		var copy = self; copy.endedAction = action; return copy
	}
	
	final public class Coordinator {
		var startLocation: CGPoint = .zero
		var localStartLocation: CGPoint = .zero
		var active = false
	}
	
	fileprivate enum State { case began, changed, ended, other }
	
	// Shared by both platforms
	fileprivate func handle(_ state: State, location: CGPoint,
							localLocation: () -> CGPoint, coordinator c: Coordinator) {
		if state == .began {
			c.startLocation = location
			c.localStartLocation = localLocation()
			c.active = false
		}
		
		let value = Value(startLocation: c.startLocation,
						  localStartLocation: c.localStartLocation,
						  location: location,
						  translation: CGSize(width: location.x - c.startLocation.x,
											  height: location.y - c.startLocation.y))
		
		switch state {
			case .began, .changed:
				if !c.active,
				   hypot(value.translation.width, value.translation.height) >= minimumDistance {
					c.active = true
				}
				if c.active { changedAction?(value) }
			case .ended:
				if c.active { endedAction?(value) }
				c.active = false
			case .other:
				break
		}
	}
}

@available(macOS 26, iOS 18, *)
extension MouseButtonDragGesture where Space == LocalCoordinateSpace 
{
	init(button: Button, minimumDistance: CGFloat = 10) 
	{
		self.init(button: button, minimumDistance: minimumDistance, coordinateSpace: .local)
	}
}



#if canImport(AppKit)
@available(macOS 26, *)
extension MouseButtonDragGesture: NSGestureRecognizerRepresentable {
	private var mask: Int {
		switch button { case .left: 0x1; case .right: 0x2; case .middle: 0x4 }
	}
	
	public func makeCoordinator(converter: NSGestureRecognizerRepresentableCoordinateSpaceConverter) -> Coordinator {
		Coordinator()
	}
	
	public func makeNSGestureRecognizer(context: Context) -> NSPressGestureRecognizer {
		let r = NSPressGestureRecognizer()
		r.minimumPressDuration = 0
		r.allowableMovement = .greatestFiniteMagnitude
		r.buttonMask = mask
		return r
	}
	
	public func updateNSGestureRecognizer(_ r: NSPressGestureRecognizer, context: Context) {
		r.buttonMask = mask
	}
	
	public func handleNSGestureRecognizerAction(_ r: NSPressGestureRecognizer, context: Context) {
		let state: State = switch r.state {
			case .began: .began
			case .changed: .changed
			case .ended, .cancelled, .failed: .ended
			default: .other
		}
		handle(state,
			   location: context.converter.location(in: coordinateSpace),
			   localLocation: { context.converter.location(in: .local) },
			   coordinator: context.coordinator)
	}
}
#endif



#if canImport(UIKit)
import UIKit.UIGestureRecognizerSubclass   // lets the subclass set `state`

public final class ButtonPressGestureRecognizer: UILongPressGestureRecognizer {
	var requiredButtons: UIEvent.ButtonMask = .primary
	
	public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
		// Finger touches report no buttons; treat them as primary
		let pressed: UIEvent.ButtonMask = event.buttonMask.isEmpty ? .primary : event.buttonMask
		guard pressed == requiredButtons else {
			state = .failed
			return
		}
		super.touchesBegan(touches, with: event)
	}
}

@available(iOS 18, *)
extension MouseButtonDragGesture: UIGestureRecognizerRepresentable {
	private var mask: UIEvent.ButtonMask {
		switch button {
			case .left:   .primary
			case .right:  .secondary
			case .middle: .button(3)
		}
	}
	
	public func makeCoordinator(converter: UIGestureRecognizerRepresentableCoordinateSpaceConverter) -> Coordinator {
		Coordinator()
	}
	
	public func makeUIGestureRecognizer(context: Context) -> ButtonPressGestureRecognizer {
		let r = ButtonPressGestureRecognizer()
		r.minimumPressDuration = 0
		r.allowableMovement = .greatestFiniteMagnitude
		r.requiredButtons = mask
		return r
	}
	
	public func updateUIGestureRecognizer(_ r: ButtonPressGestureRecognizer, context: Context) {
		r.requiredButtons = mask
	}
	
	public func handleUIGestureRecognizerAction(_ r: ButtonPressGestureRecognizer, context: Context) {
		let state: State = switch r.state {
			case .began: .began
			case .changed: .changed
			case .ended, .cancelled, .failed: .ended
			default: .other
		}
		handle(state,
			   location: context.converter.location(in: coordinateSpace),
			   localLocation: { context.converter.location(in: .local) },
			   coordinator: context.coordinator)
	}
}
#endif



@available(macOS 26, iOS 18, *)
#Preview
{
	@Previewable @State var colour : Color?
	@Previewable @State var position : CGPoint = .zero
	@Previewable @State var grabOffset : CGPoint?
	
	VStack
	{
		Rectangle()
			.fill(colour ?? .gray)
			.frame(width:50,height:50)
			.coordinateSpace(.named("rect"))
			.offset(x:position.x,y:position.y)
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
	.frame(width: 300,height:300)
}
