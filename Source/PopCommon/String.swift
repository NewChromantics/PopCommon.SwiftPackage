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
}

