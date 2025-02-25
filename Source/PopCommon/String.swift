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

extension StringProtocol
{
	public subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
	public subscript(range: Range<Int>) -> SubSequence {
		let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
		return self[startIndex..<index(startIndex, offsetBy: range.count)]
	}
	public subscript(range: ClosedRange<Int>) -> SubSequence {
		let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
		return self[startIndex..<index(startIndex, offsetBy: range.count)]
	}
	public subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
	public subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
	public subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
}
