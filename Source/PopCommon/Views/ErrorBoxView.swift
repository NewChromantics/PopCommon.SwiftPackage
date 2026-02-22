import SwiftUI


@available(macOS 12.0, *)
public struct ErrorBoxView : View 
{
	var error : any Error
	var context : String? = nil
	
	//	need a uuid tied to the error to dismiss
	//@State var dismissed
	@State var showCopiedToClipboard = false
	var onDismiss : (()->Void)?		//	if a dismiss callback is added, we allow user to dismiss
	
	public init(_ error: any Error,context: String? = nil, onDismiss:(()->Void)? = nil) 
	{
		self.error = error
		self.context = context
		self.onDismiss = onDismiss
	}
	
	public var body: some View 
	{
		HStack
		{
			//	balance the clipbaord icon
			Image(systemName: "exclamationmark.transmission")
				.opacity(0.5)
				.aspectRatio(contentMode: .fit)
			
			Text("\(context ?? "")\(error.localizedDescription)")
			//.lineLimit(nil)
				.lineLimit(1)
			
			Image(systemName: "list.clipboard")
				.aspectRatio(contentMode: .fit)
			
			if let onDismiss
			{
				Button(action:onDismiss)
				{
					Image(systemName: "x.circle.fill")
				}
			}
		}
		.padding(8)
		.background
		{
			RoundedRectangle(cornerRadius:5)
				.fill(.red)
		}
		.foregroundStyle(.white)
		.help(error.localizedDescription)
		.hoverCursor()
		.onTapGesture 
		{
			OnClicked()
		}
		.popover(isPresented: $showCopiedToClipboard)
		{
			HStack
			{
				GroupBox("Copied to clipboard!")
				{
					Text(error.localizedDescription)
				}
			}
			.padding(10)
		}
	}
	
	func OnClicked()
	{
		print("Copied to clipboard")
		Clipboard.set(text: error.localizedDescription)
		showCopiedToClipboard = true
		/*
		Task
		{
			withAnimation(.easeOut(duration:4))
			{
				showCopiedToClipboard = false
			}
		}*/
	}
}

#Preview 
{
	if #available(macOS 12.0, *) 
	{
		ErrorBoxView(RuntimeError("Some really really really really really really really really really really really really really really really  error message\nLine two\nLineThree"))
			.frame(maxWidth: 300)
			.padding(20)
	}
}
