import simd
import SwiftUI	//	angle


public extension simd_float2
{
	var cgSize : CGSize	{	CGSize(width: CGFloat(self.x), height: CGFloat(self.y) )	}
	var cgPoint : CGPoint	{	CGPoint(x: CGFloat(self.x), y: CGFloat(self.y) )	}
}

public extension SIMD2
{
	var string : String	{	"\(self.x) \(self.y)"	}
	//	gr: can't use literal values here
	//var xy0 : SIMD3<Scalar>	{	.init(x,y,0)	}
	//var xy1 : SIMD3<Scalar>	{	.init(x,y,1)	}
}

public extension SIMD2<Float>
{
	var xy0 : SIMD3<Scalar>	{	.init(x,y,0)	}
	var xy1 : SIMD3<Scalar>	{	.init(x,y,1)	}
}

public extension SIMD3
{
	var string : String	{	"\(self.x) \(self.y) \(self.z)"	}
	var xy : SIMD2<Scalar>	{	.init(x,y)	}
	var xz : SIMD2<Scalar>	{	.init(x,z)	}
}

public extension SIMD4
{
	var string : String	{	"\(self.x) \(self.y) \(self.z) \(self.w)"	}
}

public extension simd_float3x3
{
	var string : String
	{
		"[\(columns.0.string)\n\(columns.1.string)\n\(columns.2.string)]"
	}
}

public extension simd_float4x4
{
	var string : String
	{
		"[\(columns.0.string)\n\(columns.1.string)\n\(columns.2.string)\n\(columns.3.string)]"
	}
}

public extension simd_double3x3
{
	var string : String
	{
		"[\(columns.0.string)\n\(columns.1.string)\n\(columns.2.string)]"
	}
}

//	swizzles
public extension simd_float3
{
	var xyz0 : simd_float4	{	.init(x,y,z,0)	}
	var xyz1 : simd_float4	{	.init(x,y,z,1)	}
}

public extension simd_float4
{
	var xyz : simd_float3	{	return simd_float3(x,y,z)	}
	var xy : simd_float2	{	return simd_float2(x,y)	}
}

public extension simd_double3
{
	var xy : simd_double2	{	return simd_double2(x,y)	}
}

public extension simd_double4
{
	var xyz : simd_double3	{	return simd_double3(x,y,z)	}
	var xy : simd_double2	{	return simd_double2(x,y)	}
}

public extension simd_float4x4
{
	var topLeft3x3 : simd_float3x3
	{
		simd_float3x3( self.columns.0.xyz, self.columns.1.xyz, self.columns.2.xyz )
	}
}

public extension simd_float3x3
{
	var double3x3 : simd_double3x3
	{
		let a = simd_double3(self.columns.0)
		let b = simd_double3(self.columns.1)
		let c = simd_double3(self.columns.2)
		return simd_double3x3(a,b,c)
	}
}

public extension simd_float4
{
	mutating func Normalise()
	{
		self = simd.normalize(self)
	}
}

public extension simd_float3x3
{
	static var identity : simd_float3x3
	{
		simd_float3x3( diagonal: SIMD3<Float>(1,1,1) )
	}
	
	init(_ rowMajor3x3:[Float])
	{
		let row0 = SIMD3<Float>( rowMajor3x3[0], rowMajor3x3[1], rowMajor3x3[2] )
		let row1 = SIMD3<Float>( rowMajor3x3[3], rowMajor3x3[4], rowMajor3x3[5] )
		let row2 = SIMD3<Float>( rowMajor3x3[6], rowMajor3x3[7], rowMajor3x3[8] )
		self.init(columns: (row0,row1,row2))
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
	
	init(scale:SIMD3<Float>)
	{
		self.init(columns:(vector_float4(scale.x, 0, 0, 0),
						   vector_float4(0, scale.y, 0, 0),
						   vector_float4(0, 0, scale.z, 0),
						   vector_float4(0, 0, 0, 1)))
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
	
	
	init(translation:simd_float3,pitch:Angle = .degrees(0),yaw:Angle,scale:simd_float3 = .one)
	{
		let scaleMatrix = simd_float4x4(scale:scale)
		let rotationMatrixX = simd_float4x4(rotation: pitch, aroundAxis: SIMD3<Float>(1, 0, 0) )
		let rotationMatrixY = simd_float4x4(rotation: yaw, aroundAxis: SIMD3<Float>(0, 1, 0) )
		let translationMatrix = simd_float4x4(translation: translation )
		let localToWorld = translationMatrix * rotationMatrixY * rotationMatrixX * scaleMatrix
		self = localToWorld
	}

	init(translation:simd_float3,rotation:simd_quatf,scale:simd_float3 = .one)
	{
		let scaleMatrix = simd_float4x4(scale:scale)
		let rotationMatrix = simd_float4x4(rotation)
		let translationMatrix = simd_float4x4(translation: translation )
		let localToWorld = translationMatrix * rotationMatrix * scaleMatrix
		self = localToWorld
	}

}

