import SwiftUI


public extension View 
{
	@ViewBuilder
	func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
		if conditional 
		{
			content(self)
		} 
		else 
		{
			self
		}
	}
	
	@ViewBuilder
	func `modifierif`(_ conditional: Bool,_ modifier:(some ViewModifier)?) -> some View 
	{
		if conditional, let modifier 
		{
			self
				.modifier(modifier)
		}
		else 
		{
			self
		}
	}
}
