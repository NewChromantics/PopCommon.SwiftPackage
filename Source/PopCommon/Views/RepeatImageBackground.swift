import SwiftUI


@available(macOS 12.0, *)
public struct RepeatImageBackground : ViewModifier
{
	var image : Image
	var hueRotation = Angle(degrees: 0)
	var tint : Color? = nil
	
	public func body(content: Content) -> some View 
	{
		content
			.background
		{
			ZStack
			{
				Rectangle()
					.foregroundStyle( .image( image ) )
					.hueRotation(hueRotation)
				//	gr: this tint isnt having an effect any more? (only in dark mode??)
				//.tint(tint)
				//.blendMode(.multiply)
				Rectangle()
					.fill( tint ?? .clear )
			}
		}
	}
}

@available(macOS 12.0, *)
public extension View 
{
	func repeatImageBackground(_ image:Image,hueRotation:Angle=Angle.degrees(0),tint:Color?=nil) -> some View 
	{
		modifier(RepeatImageBackground(image:image,hueRotation:hueRotation,tint: tint))
	}
}

