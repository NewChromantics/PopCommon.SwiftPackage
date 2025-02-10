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



//	split an array into chunks
extension Array
{
	public func splitArray(maxPerChunk:Int) -> [[Self.Element]]
	{
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
