import simd
import SwiftUI	//	angle


public extension simd_float3x3
{
	static var identity : simd_float3x3
	{
		simd_float3x3( diagonal: SIMD3<Float>(1,1,1) )
	}
}

public extension simd_float4x4
{
	static var identity : simd_float4x4
	{
		//simd_float4x4( diagonal: SIMD4<Float>(1,1,1,1) )
		simd_float4x4([ 1,0,0,0,	0,1,0,0,	0,0,1,0,	0,0,0,1])
	}
	
	//	row major init that allows easier literal initialisation like
	//	gr: input row major, but using columns:().... something is wrong somewhere
	//		but the result is correct
	init(_ rowMajor4x4:[Float])
	{
		let row0 = SIMD4<Float>( rowMajor4x4[0], rowMajor4x4[1], rowMajor4x4[2], rowMajor4x4[3] )
		let row1 = SIMD4<Float>( rowMajor4x4[4], rowMajor4x4[5], rowMajor4x4[6], rowMajor4x4[7] )
		let row2 = SIMD4<Float>( rowMajor4x4[8], rowMajor4x4[9], rowMajor4x4[10], rowMajor4x4[11] )
		let row3 = SIMD4<Float>( rowMajor4x4[12], rowMajor4x4[13], rowMajor4x4[14], rowMajor4x4[15] )
		self.init(columns: (row0,row1,row2,row3))
	}
	
	init(translation:SIMD3<Float>)
	{
		self.init(columns:(vector_float4(1, 0, 0, 0),
											 vector_float4(0, 1, 0, 0),
											 vector_float4(0, 0, 1, 0),
											 vector_float4(translation.x, translation.y, translation.z, 1)))
	}
	
	init(rotation: Angle, aroundAxis: SIMD3<Float>)
	{
		let radians = rotation.radians
		let unitAxis = normalize(aroundAxis)
		let ct = cosf(Float(radians))
		let st = sinf(Float(radians))
		let ci = 1 - ct
		let x = unitAxis.x, y = unitAxis.y, z = unitAxis.z
		self.init(columns:(vector_float4(    ct + x * x * ci, y * x * ci + z * st, z * x * ci - y * st, 0),
											 vector_float4(x * y * ci - z * st,     ct + y * y * ci, z * y * ci + x * st, 0),
											 vector_float4(x * z * ci + y * st, y * z * ci - x * st,     ct + z * z * ci, 0),
											 vector_float4(                  0,                   0,                   0, 1)))
	}
}

