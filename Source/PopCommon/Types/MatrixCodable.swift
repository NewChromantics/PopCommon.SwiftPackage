/*
	make simd matrix types codable with a nice codable-output
	{	
		columns : [	[a,b,c], [d,e,f], [g,h,i]	]
	}
*/
import simd



extension simd_float3x3 : @retroactive Encodable {}
extension simd_float3x3 : @retroactive Decodable {}
extension simd_float3x3 : MatrixCodable
{
	var matrixColumns : [SIMD3<Float>]			{	[columns.0, columns.1, columns.2]	}
	init(matrixColumns c: [SIMD3<Float>]) throws	{	self.init(c[0], c[1], c[2])	}
}

extension simd_float4x4 : @retroactive Encodable {}
extension simd_float4x4 : @retroactive Decodable {}
extension simd_float4x4 : MatrixCodable
{
	var matrixColumns : [SIMD4<Float>]			{	[columns.0, columns.1, columns.2, columns.3]	}
	
	init(matrixColumns c: [SIMD4<Float>]) throws	{	self.init(c[0], c[1], c[2], c[3])	}
}




/// Wire format for any column-major float matrix.
/// Encodes as `{ "columns": [[a,b,c], [d,e,f], [g,h,i]] }`.
struct SerialisedMatrix : Codable
{
	/// Outer array = columns, inner array = elements within each column.
	var columns : [[Float]]
	
	var columnCount : Int	{	columns.count			}
	var rowCount    : Int	{	columns.first?.count ?? 0	}
	
	init(columns: [[Float]])
	{
		self.columns = columns
	}
	
	/// Throws a descriptive `DecodingError` if the shape doesn't match.
	func requireSize(columns expectedColumns: Int, rows expectedRows: Int) throws
	{
		guard columns.count == expectedColumns else
		{
			throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription:
														"Expected \(expectedColumns) columns, got \(columns.count)"))
		}
		for (i, col) in columns.enumerated()
		{
			guard col.count == expectedRows else
			{
				throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription:
															"Expected \(expectedRows) rows in column \(i), got \(col.count)"))
			}
		}
	}
}

// MARK: - SimdFloatVector

/// Constraint shared by SIMD3<Float> and SIMD4<Float> (and SIMD2<Float> etc).
/// Lets `MatrixCodable` read the row count and convert columns to/from [Float]
/// without knowing the concrete vector type.
protocol SimdFloatVector : SIMD where Scalar == Float
{
	/// Returns the elements of this vector as a plain [Float].
	var floatArray : [Float]	{	get	}
	
	/// Reconstructs the vector from a [Float] that is already the right length.
	init(floatArray: [Float])
}

extension SIMD2<Float> : SimdFloatVector
{
	var floatArray : [Float]		{	[x, y]	}
	init(floatArray a: [Float])		{	self.init(a[0], a[1])	}
}

extension SIMD3<Float> : SimdFloatVector
{
	var floatArray : [Float]		{	[x, y, z]	}
	init(floatArray a: [Float])		{	self.init(a[0], a[1], a[2])	}
}

extension SIMD4<Float> : SimdFloatVector
{
	var floatArray : [Float]		{	[x, y, z, w]	}
	init(floatArray a: [Float])		{	self.init(a[0], a[1], a[2], a[3])	}
}

// MARK: - MatrixCodable

/// Adopt this on any simd matrix type to get `Codable` for free.
///
/// Requirements:
/// - `Column`: the SIMD column type (row count is inferred from `Column.scalarCount`)
/// - `matrixColumns`: just list your columns — `[columns.0, columns.1, ...]`
/// - `init(matrixColumns:)`: reconstruct from an already-validated array of columns
///
/// Everything else — `SerialisedMatrix` conversion, `encode`, `init(from:)` — is
/// provided by the protocol extension.
protocol MatrixCodable : Codable
{
	associatedtype Column : SimdFloatVector
	
	/// Return the matrix's columns in order.
	var matrixColumns : [Column]	{	get	}
	
	/// Reconstruct the matrix from a validated array of columns.
	init(matrixColumns: [Column]) throws
}

extension MatrixCodable
{
	/// Row count comes from the SIMD vector's scalar count — no manual bookkeeping.
	static var matrixRowCount : Int	{	Column.scalarCount	}
	
	public func encode(to encoder: any Encoder) throws
	{
		let serialised = SerialisedMatrix(columns: matrixColumns.map(\.floatArray))
		try serialised.encode(to: encoder)
	}
	
	public init(from decoder: any Decoder) throws
	{
		let serialised = try SerialisedMatrix(from: decoder)
		let expectedRows = Self.matrixRowCount
		try serialised.requireSize(columns: serialised.columnCount, rows: expectedRows)
		let cols = serialised.columns.map { Column(floatArray: $0) }
		try self.init(matrixColumns: cols)
	}
}
