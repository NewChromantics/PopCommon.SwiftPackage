import SwiftUI


public struct EnumDropDown<ENUM:CaseIterable&Equatable&Hashable,LabelView:View> : View 
{
	@Binding var value : ENUM
	var label : String
	var labelView : (ENUM) -> LabelView
	
	public init(label:String, value:Binding<ENUM>, labelView:@escaping(ENUM) -> LabelView)
	{
		self._value = value
		self.labelView = labelView
		self.label = label
	}
	
	public var body: some View 
	{
		Picker(label,selection:$value)
		{
			let cases = Array( ENUM.allCases.enumerated() )
			ForEach(cases,id:\.offset)
			{ 
				index,enumCase in
				labelView(enumCase)
					.tag(enumCase)
			}
		}
		//.labelsHidden()
	}
	
	func OnClicked(_ newValue:ENUM)
	{
		self.value = newValue
	}
	
}


