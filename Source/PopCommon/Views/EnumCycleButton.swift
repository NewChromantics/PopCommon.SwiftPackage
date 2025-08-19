import SwiftUI


public struct EnumCycleButton<ENUM:CaseIterable&Equatable,LabelContentView: View> : View 
{
	@Binding var value : ENUM
	var label : () -> LabelContentView
	
	public init(value:Binding<ENUM>, label: @escaping () -> LabelContentView)
	{
		self._value = value
		self.label = label
	}
	
	public var body: some View 
	{
		//	I wanna pass a button style in here
		Button(action:ChangeToNextValue)
		{
			label()
		}
	}
	
	func ChangeToNextValue()
	{
		let next = GetNextValue(self.value)
		self.value = next
	}
	
	func GetNextValue(_ prev:ENUM) -> ENUM
	{
		let prevIndex = ENUM.allCases.firstIndex(of: prev)
		guard let prevIndex else
		{
			return ENUM.allCases.first!
		}
		let nextIndex = ENUM.allCases.index(after: prevIndex)
		if nextIndex == ENUM.allCases.endIndex
		{
			return ENUM.allCases.first!
		}
		return ENUM.allCases[nextIndex]
	}
}
