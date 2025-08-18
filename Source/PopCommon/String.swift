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


public extension Int
{
	var bytesFormattedAsString : String
	{
		let kb = self / 1024
		let mbFloat = Float(self) / (1024.0*1024.0)
		let gbFloat = Float(self) / (1024.0*1024.0*1024.0)
		
		if kb < 1
		{
			return "\(self)bytes"
		}
		
		//	under a meg, use kb
		if mbFloat < 1.0
		{
			return "\(kb)kb"
		}
		
		//	show 9.55mb but not 250mb
		if mbFloat < 10.0
		{
			let mb00 = String(format:"%.02fmb",mbFloat)
			return mb00
		}
		if gbFloat < 1.0
		{
			let mb = Int(mbFloat)
			return "\(mb)mb"
		}
		
		//	gigabytes!
		let gb00 = String(format:"%.02fgb",gbFloat)
		return gb00
	}
}
