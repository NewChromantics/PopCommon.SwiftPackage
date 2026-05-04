import SwiftUI

//	https://stackoverflow.com/a/58632759/355753
public extension View 
{
	func border(width: CGFloat, edges: [Edge], color: Color) -> some View 
	{
		overlay( EdgeBorder(width: width, edges: edges).foregroundColor(color))
	}
	
	func border(width: CGFloat, edge: Edge, color: Color) -> some View 
	{
		border(width:width, edges:[edge], color:color)
	}
}

public extension Edge
{
	func GetEdgeRect(parentRect:CGRect,thickness:CGFloat) -> CGRect
	{
		switch self
		{
			case .top:		return CGRect(x: parentRect.minX, y: parentRect.minY, width: parentRect.width, height: thickness)
			case .bottom:	return CGRect(x: parentRect.minX, y: parentRect.maxY - thickness, width: parentRect.width, height: thickness)
			case .leading:	return CGRect(x: parentRect.minX, y: parentRect.minY, width: thickness, height: parentRect.height)
			case .trailing:	return CGRect(x: parentRect.maxX - thickness, y: parentRect.minY, width: thickness, height: parentRect.height)
		}
	}
}

public struct EdgeBorder : Shape  
{
	var width: CGFloat
	var edges: [Edge]
	
	public func path(in rect: CGRect) -> Path 
	{
		var path = Path()
		edges.forEach
		{
			path.addRect( $0.GetEdgeRect(parentRect:rect, thickness: width) )
		}
		return path
	}
}
