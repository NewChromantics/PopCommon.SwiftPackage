import SwiftUI


public struct EnumRadioToggle<ENUM:CaseIterable&Equatable,LabelView:View> : View 
{
	@Binding var value : ENUM
	var label : (ENUM,Bool) -> LabelView
	
	public init(value:Binding<ENUM>, label:@escaping(ENUM,Bool) -> LabelView)
	{
		self._value = value
		self.label = label
	}
	
	public var body: some View 
	{
		HStack(spacing: 0)
		{
			ForEach(Array(ENUM.allCases.enumerated()),id:\.offset)
			{
				index,enumCase in
				let isSelected = value == enumCase
				Button(action:{OnClicked(enumCase)})
				{
					label(enumCase,isSelected)
				}
				//.buttonStyle(.plain)
				.buttonStyle(.borderless)
				//.disabled(isSelected)
			}
		}
	}
	
	func OnClicked(_ newValue:ENUM)
	{
		self.value = newValue
	}
	
}

internal enum EnumRadioToggleTest : CaseIterable
{
	case One, Two, Three
}

@available(macOS 14.0, *)
#Preview 
{
	@Previewable @State var value = EnumRadioToggleTest.One
	
	EnumRadioToggle(value: $value)
	{
		caseValue,isSelected in
		//let selected = caseValue == value
		Label("\(caseValue)", systemImage: "bolt")
			.padding(10)
			.foregroundStyle(isSelected ? .white : .black)
			.background
		{
			RoundedRectangle(cornerRadius: 5)
				.fill(isSelected ? .blue : .black.opacity(0.1))
				//.stroke(isSelected ? .white : .black)
		}
		//Text("Hello")
	}
	.padding(20)
}
