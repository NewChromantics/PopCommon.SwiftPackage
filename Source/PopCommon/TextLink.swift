import SwiftUI


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


//@available(macOS 11.0, *)	//	open url
//@available(macOS 12.0, *)	//	overlay for fake underline
@available(macOS 13.0, iOS 16, *)	//	underline
public struct TextLinkModifier : ViewModifier
{
	@Environment(\.openURL) private var openURL
	
	var url : URL?		//	if no url, stays as text
	var linkColour : Color?
	
	public func body(content: Content) -> some View 
	{
		let urlOpenFunctor = GetOpenUrlFunctor(url: url)
		
		if let urlOpenFunctor
		{
			content
				.underline()//color:linkColour)
				//.quickLookPreview(url)
				//.foregroundStyle(linkColour)
				.modifier(HoverCursorModifier())
				.onTapGesture 
				{
					urlOpenFunctor(url!)
				}
			/*macos 12
				.overlay	//	fake underline
				{
						Rectangle()
							.fill(Color.white)
							.frame(height: 1)
				}
			 */
		}
		else
		{
			content
		}
	}
	
#if canImport(AppKit)
	static func ShowInFinder(url:URL)
	{
		NSWorkspace.shared.activateFileViewerSelecting([url])
	}
#endif
	
	func OpenDefaultApplication(url:URL)
	{
		openURL(url)
		{
			result in
			if !result
			{
				print("url \(url) failed to open")
			}
		}
	}
	
	func GetOpenUrlFunctor(url:URL?) -> ((URL)->())?
	{
		if url?.isFileURL ?? false
		{
#if os(macOS)
			return Self.ShowInFinder
#endif
			//	if ios, find a nice way to show a sharing sheet and share file
		}
		if url != nil
		{
			return OpenDefaultApplication
		}
		
		return nil
	}
		
}

@available(macOS 13.0, iOS 16.0, *)
public extension View
{
	func link(url:URL?,linkColour:Color = .blue) -> some View 
	{
		modifier(TextLinkModifier(url: url,linkColour: linkColour))
	}

}

#Preview
{
	if #available(macOS 13.0, iOS 16, *) 
	{
		Text("Google")
			.link(url: URL(string: "https://google.com"))
	}
}

