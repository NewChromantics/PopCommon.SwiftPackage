import Foundation

//	make a decoder we can pass around, this allows us to decode multiple structs
public extension JSONDecoder 
{
	private struct DecoderCloner: Decodable {
		var decoder: Decoder
		init(from decoder: Decoder) throws {
			self.decoder = decoder
		}
	}
	
	func decoder(for data: Data) throws -> Decoder {
		try decode(DecoderCloner.self, from: data).decoder
	}
}


