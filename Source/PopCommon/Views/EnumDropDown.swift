import SwiftUI


public struct EnumDropDown<ENUM:CaseIterable&Equatable&Hashable,ValueView:View,LabelView:View> : View 
{
	@Binding var value : ENUM
	var valueView : (ENUM) -> ValueView
	var labelView : () -> LabelView
	
	public init(value:Binding<ENUM>,valueView:@escaping(ENUM) -> ValueView,labelView:@escaping()->LabelView)
	{
		self._value = value
		self.valueView = valueView
		self.labelView = labelView
	}
	
	public var body: some View 
	{
		//	in order to respect .controlSize() we have to do the label manually
		//	when placed in the Picker()'s label, .controlSize from above has no effect
		HStack
		{
			labelView()
			
			Picker(selection:$value)
			{
				ForEach(Array(ENUM.allCases), id: \.self)
				{ 
					enumCase in
					valueView(enumCase)
						.tag(enumCase)
				}
			}
		label:
			{
				//labelView()	//	see above
				EmptyView()
			}
			.labelsHidden()
		}
	}
	
}


public extension EnumDropDown where ValueView == Text 
{
	//	init with custom label and default entry
	init(value: Binding<ENUM>,labelView: @escaping () -> LabelView) where ENUM: CustomStringConvertible
	{
		self._value = value
		self.valueView = { Text($0.description) }
		self.labelView = labelView
	}
}


public extension EnumDropDown where LabelView == Text 
{
	//	init with a string label but user provided value view
	init(label: String,value: Binding<ENUM>,valueView: @escaping (ENUM) -> ValueView)
	{
		self._value = value
		self.valueView = valueView
		self.labelView = { Text(label) }
	}
	
}


public extension EnumDropDown where LabelView == EmptyView 
{
	//	init with a string label but user provided value view
	init(value: Binding<ENUM>,valueView: @escaping (ENUM) -> ValueView)
	{
		self._value = value
		self.valueView = valueView
		self.labelView = { EmptyView() }
	}
	
}

public extension EnumDropDown where ValueView == Text, LabelView == Text 
{
	//	init with a string label and default Text() drop down entry
	init(label: String, value: Binding<ENUM>) where ENUM: CustomStringConvertible 
	{
		self._value = value
		self.valueView = { Text($0.description) }
		self.labelView = { Text(label) }
	}
}


public extension EnumDropDown where ValueView == Text, LabelView == EmptyView 
{
	//	a drop down and nothing else
	init(value: Binding<ENUM>) where ENUM: CustomStringConvertible 
	{
		self._value = value
		self.valueView = { Text($0.description) }
		self.labelView = { EmptyView() }
	}
}
