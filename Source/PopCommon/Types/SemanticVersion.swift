import SwiftUI

//	You know the public will demand it.
typealias SemVer = SemanticVersion


public struct SemanticVersion : CustomStringConvertible
{
	public var description: String
	{
		return "\(major).\(minor).\(patch)"
	}
	
	var major : Int
	var minor : Int
	var patch : Int
	
	public init(_ major: Int,_  minor: Int,_  patch: Int) 
	{
		self.major = major
		self.minor = minor
		self.patch = patch
	}
	
	public init(_ MajorMinorPatch:[Int]) throws
	{
		if ( MajorMinorPatch.count != 3 )
		{
			throw RuntimeError("Version(\(MajorMinorPatch)) expects 3 elements.")
		}
		self.major = MajorMinorPatch[0]
		self.minor = MajorMinorPatch[1]
		self.patch = MajorMinorPatch[2]
	}
}
