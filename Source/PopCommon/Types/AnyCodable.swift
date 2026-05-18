import Foundation 




public struct AnyCodable : Codable
{	
	let value: Any

	public var string : String?		{	value as? String	}
	//public var uint32 : UInt32?		{	value as? UInt32	}
	public var uint32 : UInt32?		{	int.map{ UInt32($0) }	}
	public var int : Int?			{	value as? Int	}
	public var bool : Bool?			{	value as? Bool	}
	
	public init(_ value: Any) { self.value = value }
	
	public init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()
		if let v = try? container.decode(Bool.self)                      { value = v }
		else if let v = try? container.decode(Int.self)                  { value = v }
		else if let v = try? container.decode(Double.self)               { value = v }
		else if let v = try? container.decode(String.self)               { value = v }
		else if let v = try? container.decode([AnyCodable].self)         { value = v.map(\.value) }
		else if let v = try? container.decode([String: AnyCodable].self) { value = v.mapValues(\.value) }
		else { value = NSNull() }
	}
	
	public func encode(to encoder: any Encoder) throws {
		var container = encoder.singleValueContainer()
		switch value {
			case let v as Bool:          try container.encode(v)
			case let v as Int:           try container.encode(v)
			case let v as Double:        try container.encode(v)
			case let v as String:        try container.encode(v)
			case let v as [Any]:         try container.encode(v.map { AnyCodable($0) })
			case let v as [String: Any]: try container.encode(v.mapValues { AnyCodable($0) })
			default:                     try container.encodeNil()
		}
	}
}

extension AnyCodable : Equatable, Hashable
{
	public static func == (lhs: Self, rhs: Self) -> Bool
	{
		return 	lhs.string == rhs.string && 
		lhs.uint32 == rhs.uint32 &&
		lhs.int == rhs.int &&
		lhs.bool == rhs.bool
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(string)
		hasher.combine(uint32)
		hasher.combine(int)
		hasher.combine(bool)
	}
}
	
