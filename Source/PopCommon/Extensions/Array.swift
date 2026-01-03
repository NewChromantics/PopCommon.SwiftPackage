/*
	Array utilities
*/
import math_h	//	ceil()

//	this can now be done with 
//		import Algoritm
//		let unique = Array( origArray.uniqued() )
public extension Array where Element: Hashable
{
	func reduce() -> Set<Self.Element>
	{
		return Set(self.map{$0})
	}
}

//	https://stackoverflow.com/a/30593673/355753
//	Array[safeIndex:99999] returns nil if oob
extension Collection 
{
	// Returns the element at the specified index if it is within bounds, otherwise nil.
	subscript(safe index: Index) -> Element? 
	{
		indices.contains(index) ? self[index] : nil
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



//	split an array into chunks
extension Array
{
	public func splitArray(maxPerChunk:Int) -> [[Self.Element]]
	{
		if self.count == 0
		{
			return []
		}
		let maxPerChunkf = Double(Swift.max(Int(1),maxPerChunk))
		let chunksf = Double(self.count) / maxPerChunkf
		let chunks = Swift.max( 1, ceil(chunksf) )
		let elementsPerChunk = Int( ceil( Double(self.count) / chunks ) )
		
		let chunkedArray = stride(from: 0, to: self.count, by: elementsPerChunk).map 
		{
			firstIndex in
			let lastIndex = Swift.min(firstIndex + elementsPerChunk, self.count)
			return Array( self[firstIndex..<lastIndex] )
		}
		
		return chunkedArray
	}
}

//	remove first element if present
extension Array
{
	public mutating func popFirst() -> Self.Element?
	{
		let first = self.first
		guard let first else
		{
			return nil
		}
		self.removeFirst()
		return first
	}
}

extension Array 
{
	public mutating func mutateEach(by transform: (inout Element) throws -> Void) rethrows 
	{
		self = try map 
		{ 
			element in
			var element = element
			try transform(&element)
			return element
		}
	}
}
