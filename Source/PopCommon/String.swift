/*
	String utilities
*/

extension String
{
	//	returns suffix if it exists
	public func suffix(after:String) -> String?
	{
		if !self.starts(with: after)
		{
			return nil
		}
		
		let Suffix = String( self.suffix(self.count - after.count) )
		return Suffix
	}

	//	returns string without this suffix
	//	api named to match .trimPrefix
	public func trimSuffix(_ suffix:String) -> String
	{
		if !self.hasSuffix(suffix)
		{
			return self
		}
		
		let prefix = self.dropLast(suffix.count)
		return String(prefix)
	}
}
