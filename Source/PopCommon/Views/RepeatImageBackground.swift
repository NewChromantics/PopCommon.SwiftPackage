import SwiftUI


@available(macOS 12.0, *)
public struct RepeatImageBackground : ViewModifier
{
	var image : Image
	var hueRotation = Angle(degrees: 0) 
	
	public func body(content: Content) -> some View 
	{
		content
			.background
		{
			Rectangle()
				.foregroundStyle( .image( image ) )
				.hueRotation(hueRotation)
		}
	}
}

@available(macOS 12.0, *)
public extension View 
{
	func repeatImageBackground(_ image:Image,hueRotation:Angle=Angle.degrees(0)) -> some View 
	{
		modifier(RepeatImageBackground(image:image,hueRotation:hueRotation))
	}
}

