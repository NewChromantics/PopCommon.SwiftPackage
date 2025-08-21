import SwiftUI



public extension View
{
	@available(macOS 13,iOS 16.0, *)
	func blackboxStyle(labelPadding:CGFloat) -> some View 
	{
		modifier(BlackBoxStyling(labelPadding: labelPadding))
	}
	
	@available(macOS 13,iOS 16.0, *)
	func blackboxStyle() -> some View 
	{
		modifier(BlackBoxStyling())
	}
	
	@available(macOS 13,iOS 16.0, *)
	func dismissableStyle(iconName:String?="exclamationmark.triangle", colour:Color = .red) -> some View 
	{
		modifier(DismissableBoxStyling(messageiconName: iconName, colour:colour))
			.modifier(HoverCursorModifier())
		
	}
}



public struct PokerButton: ButtonStyle
{
	var overrideBackground : Color? = nil
	var labelPadding = PokerButton.labelPadding
	public static var labelPadding = CGFloat(10)
	public static var boxCornerRadius = CGFloat(5)
	
	//	https://stackoverflow.com/a/69990897/355753
	@Environment(\.isEnabled) var isEnabled: Bool
	
	public init(overrideBackground: Color?=nil, labelPadding:CGFloat=PokerButton.labelPadding) 
	{
		self.overrideBackground = overrideBackground
		self.labelPadding = labelPadding
	}
	
	public func makeBody(configuration: Configuration) -> some View
	{
		let bg = overrideBackground ?? ( isEnabled ? Color("ActionButtonBackground") : Color("ActionButtonDisabledBackground") )
		let fg = isEnabled ? Color("ActionButtonForeground") : Color("ActionButtonDisabledForeground")
		let borderColour = fg
		
		let ReliefSize = 4.0
		
		let press = configuration.isPressed ? ReliefSize*0.50 : 0.0
		let offset = isEnabled ? press : ReliefSize
		let shadowSize = ReliefSize - offset
		
		
		/*
		 self.didTapButton = true
		 DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
		 self.didTapButton = false
		 }
		 */
		configuration.label
			.lineLimit(1)
			.padding(labelPadding)
			.foregroundColor(fg)
			.clipShape(RoundedRectangle(cornerRadius: PokerButton.boxCornerRadius))	//	clip massive labels (eg, overflowing images)
			.background(
				RoundedRectangle(cornerRadius: PokerButton.boxCornerRadius)
					.fill(bg)
				//.stroke(borderColour,lineWidth: 1)
					.shadow(color:borderColour,radius:0,x:shadowSize,y:shadowSize)
			)
		//.minimumScaleFactor(0.60)
			.offset(x:offset,y:offset)
	}
}


public struct PokerToggle : ToggleStyle
{
	//	https://stackoverflow.com/a/69990897/355753
	@Environment(\.isEnabled) var isEnabled: Bool
	
	public init()
	{
	}
	
	public func makeBody(configuration: Configuration) -> some View
	{
		//let bg = isEnabled ? Color("ActionButtonBackground") : Color("ActionButtonDisabledBackground")
		let bg = configuration.isOn ? Color("ActionToggledBackground") : Color("ActionButtonBackground")
		let fg = isEnabled ? Color("ActionButtonForeground") : Color("ActionButtonDisabledForeground")
		let borderColour = fg
		
		let ReliefSize = 4.0
		
		let press = configuration.isOn ? ReliefSize*0.50 : 0.0
		let offset = isEnabled ? press : ReliefSize
		let shadowSize = ReliefSize - offset
		
		
		/*
		 self.didTapButton = true
		 DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
		 self.didTapButton = false
		 }
		 */
		configuration.label
			.lineLimit(1)
			.padding(PokerButton.labelPadding)
			.foregroundColor(fg)
			.background(
				RoundedRectangle(cornerRadius: PokerButton.boxCornerRadius)
					.fill(bg)
				//.stroke(borderColour,lineWidth: 1)
					.shadow(color:borderColour,radius:0,x:shadowSize,y:shadowSize)
			)
		//.minimumScaleFactor(0.60)
			.offset(x:offset,y:offset)
			.onTapGesture 
			{
				configuration.isOn.toggle()
			}
	}
}

@available(macOS 13,iOS 16.0, *)
struct BlackBoxStyling : ViewModifier
{
	var labelPadding = PokerButton.labelPadding
	
	public func body(content: Content) -> some View 
	{
		content
			.lineLimit(1)
			.minimumScaleFactor(0.5)
			.fontWeight(.bold)
			.padding(labelPadding)	//	to match button
			.foregroundStyle(.white)
			.background(.black)
			.cornerRadius(PokerButton.boxCornerRadius)
		
	}
}



@available(macOS 13,iOS 16.0, *)
struct DismissableBoxStyling : ViewModifier
{
	var messageiconName : String? = "x.circle"
	var messageiconSize : CGFloat	{	messageiconName != nil ? 20 : 0	}
	
	var xiconName : String = "x.circle"
	var colour : Color
	var foregroundColour : Color = .white
	//var onDismiss : ()
	//	could use geometry size to automate this
	var xiconSize = CGFloat(30)
	var xiconOffsetFactorX = CGFloat(0.5)
	var xiconOffsetFactorY = CGFloat(0.5)
	var xiconOffset : CGSize	{	CGSize(width:xiconSize*xiconOffsetFactorX,height:xiconSize * -xiconOffsetFactorY)	}
	var xiconPadding : CGFloat	{	xiconSize * 0.15	}
	
	public func body(content: Content) -> some View 
	{
		content
			.lineLimit(1)
			.minimumScaleFactor(0.5)
			.padding(10)
			.padding(.leading,messageiconSize)
			.foregroundStyle(foregroundColour)
			.background(colour)
			.cornerRadius(10)
		.overlay
		{
			if let messageiconName
			{
				Image(systemName: messageiconName)
					.resizable()
					.scaledToFit()
					.foregroundStyle(foregroundColour)
					.padding(10)
					.fontWeight(.bold)
					.frame(maxWidth:.infinity, alignment: .leading)
			}
		}
			.overlay
		{
			VStack
			{
				Image(systemName: xiconName)
					.resizable()
					.scaledToFit()
					.fontWeight(.bold)
					.padding(xiconPadding)
					.background(colour)
					.foregroundStyle(foregroundColour)
					.clipShape(Circle())
					.frame(width: xiconSize,height: xiconSize)
			}
			.frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .topTrailing)
			.offset(xiconOffset)			
		}
	
	}
}


@available(macOS 14,iOS 17.0, *)
#Preview
{
	@Previewable @State var toggle = true
	
	Button(action:{})
	{
		Text("Poker button")
	}
	.buttonStyle(PokerButton())
	
	Toggle(isOn: $toggle)
	{
		Text("Poker toggle = \(toggle)")
	}
	.toggleStyle(PokerToggle())
	
	Text("Some Text")
		.blackboxStyle()
	
	Text("Oh no!")
		.dismissableStyle()
		.onTapGesture {
			print("Oh no")
		}
	
	
	Text("No icon")
		.dismissableStyle(iconName: nil,colour: .blue)
		.onTapGesture {
			print("no icon")
		}
}

