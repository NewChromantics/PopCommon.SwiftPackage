/*
	Array utilities
*/

extension Array where Element: Hashable
{
	func reduce() -> Set<Self.Element>
	{
		return Set(self.map{$0})
	}
	
}
