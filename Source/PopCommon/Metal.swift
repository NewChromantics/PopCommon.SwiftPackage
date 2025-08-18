import Metal


public extension MTLRenderCommandEncoder
{
	//	setXXBytes with auto-size
	//	todo: array version
	func setVertexBytes<TYPE>(_ data:inout TYPE,index:Int)// where TYPE:~Copyable
	{
		let size = MemoryLayout<TYPE>.stride
		//self.setVertexBytes( &data, length:size, index: index)
		withUnsafePointer(to: &data)
		{
			dataPtr in
			self.setVertexBytes( dataPtr, length:size, index: index)
		}
	}
	
	func setFragmentBytes<TYPE:Copyable>(_ data:inout TYPE,index:Int)
	{
		let size = MemoryLayout<TYPE>.stride
		//self.setFragmentBytes( &data, length:size, index: index)
		withUnsafePointer(to: &data)
		{
			dataPtr in
			self.setFragmentBytes( dataPtr, length:size, index: index)
		}
	}
}

public extension MTLComputeCommandEncoder
{
	//	setXXBytes with auto-size
	//	todo: array version
	func setBytes<TYPE>(_ data:inout TYPE,index:Int)// where TYPE:~Copyable
	{
		let size = MemoryLayout<TYPE>.stride
		//self.setVertexBytes( &data, length:size, index: index)
		withUnsafePointer(to: &data)
		{
			dataPtr in
			self.setBytes( dataPtr, length:size, index: index)
		}
	}
	
}

