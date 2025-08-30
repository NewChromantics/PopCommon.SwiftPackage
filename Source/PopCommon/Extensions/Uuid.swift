import Foundation



public extension UInt32
{
	var bytes : [UInt8]
	{
		var self32 = self
		return withUnsafeBytes(of: &self32)
		{
			bytes in
			return [bytes[0],bytes[1],bytes[2],bytes[3]]
		}
	}
}


public extension UUID
{
	init(_ a:UInt32,_ b:UInt32,_ c:UInt32,_ d:UInt32)
	{
		self = Self.fromInts(a,b,c,d)
	}
	
	//	fill 128 bits
	static func fromInts(_ a:UInt32,_ b:UInt32,_ c:UInt32,_ d:UInt32) -> UUID
	{
		let bytes = a.bytes + b.bytes + c.bytes + d.bytes
		var uuid64 : uuid_t = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
		withUnsafeMutablePointer(to: &uuid64)
		{
			bytes64 in
			bytes64.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<uuid_t>.size) 
			{
				ptr in
				var buf = UnsafeMutableBufferPointer<UInt8>(start: ptr,count: 16)
				bytes.copyBytes(to:buf)
			}
		}
		return UUID(uuid: uuid64)
	}
}
