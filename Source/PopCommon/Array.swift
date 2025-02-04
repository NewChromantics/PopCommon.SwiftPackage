/*
	Array utilities
*/

//	this can now be done with 
//		import Algoritm
//		let unique = Array( origArray.uniqued() )
extension Array where Element: Hashable
{
	public func reduce() -> Set<Self.Element>
	{
		return Set(self.map{$0})
	}
	
}

//	https://stackoverflow.com/a/49046981/355753
extension Sequence where Element : Numeric 
{
	//	Returns the sum of all elements in the collection
	public func sum() -> Element 
	{
		return reduce(0, +) 
	}
}
