import SwiftUI


/*
	Input to the draggable offset is in pixel/geometry space, therefore as your view changes
	these numbers are going to get whacky
 
 Use a dynamic binding to convert
	GeometryReader()
	{
		geo in
		let point0Binding = Binding<CGSize>(
			get:
			{
				self.posNormalised * reader.size
			},
			set:
			{ 
				self.posNormalised = ($0 / reader.size)
			}
		 )
 
		Circle()
			.draggableOffset( geometryPosition: point0Binding )
	}
*/
public struct DraggableOffet : ViewModifier 
{
	@Binding var geometryPosition : CGSize
	
	//	in the world of UI - always rememeber where you started and write Orig+Delta :)
	//	when nil, we're not dragging
	@State var startDragPosition : CGSize? = nil
	
	public func body(content: Content) -> some View 
	{
		let drag = DragGesture()
			.onChanged 
		{ 
			dragMeta in
			startDragPosition = startDragPosition ?? geometryPosition
			geometryPosition = startDragPosition! + dragMeta.translation
		}
		.onEnded 
		{ 
			dragMeta in
			startDragPosition = nil
		}
		return content.offset(geometryPosition).gesture(drag)
	}
}

internal extension CGSize
{
	var cgPoint : CGPoint	{	CGPoint(x:self.width,y:self.height)	}
}

public struct DraggablePosition : ViewModifier 
{
	@Binding var geometryPosition : CGPoint
	
	//	in the world of UI - always rememeber where you started and write Orig+Delta :)
	//	when nil, we're not dragging
	@State var startDragPosition : CGPoint? = nil
	
	public func body(content: Content) -> some View 
	{
		let drag = DragGesture()
			.onChanged 
		{ 
			dragMeta in
			startDragPosition = startDragPosition ?? geometryPosition
			geometryPosition = startDragPosition! + dragMeta.translation.cgPoint
		}
		.onEnded 
		{ 
			dragMeta in
			startDragPosition = nil
		}
		return content.position(geometryPosition).gesture(drag)
	}
}


public extension View 
{
	func draggableOffset(geometryPosition:Binding<CGSize>) -> some View
	{
		return self.modifier( DraggableOffet(geometryPosition:geometryPosition) )
	}
	
	func draggablePosition(geometryPosition:Binding<CGPoint>) -> some View
	{
		return self.modifier( DraggablePosition(geometryPosition:geometryPosition) )
	}
}
