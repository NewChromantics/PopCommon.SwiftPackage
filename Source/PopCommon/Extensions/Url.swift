import Foundation


public extension URL 
{
	//	filename without extension
	var filenameWithoutExtension : String 
	{
		return self.deletingPathExtension().lastPathComponent
	}
	
	//	returns nil if file doesnt exist or path not valid
	static func GetExistingFile(filePath:String) -> URL?
	{
		if !FileManager.default.fileExists(atPath: filePath)
		{
			return nil
		}
		return URL(fileURLWithPath: filePath)
	}
}

public extension FileManager
{
	//	strange that OS doesnt provide a file exists function for filepaths
	//	when urls are used for paths
	func fileExists(atPath:URL) -> Bool
	{
		return self.fileExists(atPath: atPath.path)
	}
}
