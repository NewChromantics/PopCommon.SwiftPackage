import Foundation


public extension URL 
{
	//	filename without extension
	var filenameWithoutExtension : String 
	{
		return self.deletingPathExtension().lastPathComponent
	}
	
	
}
