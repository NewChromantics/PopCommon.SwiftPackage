import SwiftUI


public extension View 
{
	@ViewBuilder
	public func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
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
	public func `modifierif`(_ conditional: Bool,_ modifier:(some ViewModifier)?) -> some View 
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
