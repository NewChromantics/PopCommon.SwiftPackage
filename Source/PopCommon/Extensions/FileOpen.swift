import SwiftUI
import UniformTypeIdentifiers




//	nil if cancelled
@available(macOS 11.0, *)	//	for UTTypes filter
@MainActor
public func SaveFileDialog(contentTypes:[UTType]) async throws -> URL?
{
#if canImport(AppKit)
	let panel = NSSavePanel()
	panel.canCreateDirectories = true
	panel.allowedContentTypes = contentTypes
	
	let openResult = panel.runModal()
	
	//	user cancelled
	if openResult == .init(rawValue: 0)
	{
		return nil
	}
	
	if openResult != .OK
	{
		throw RuntimeError("File save failed \(openResult)")
	}
	guard let filePath = panel.url else
	{
		throw RuntimeError("File save, but no file")
	}
	return filePath
#else
	//	todo: on ios, some 
	throw RuntimeError("File import not supported")
#endif
}


func BrowseForDirectoryPath() async throws -> URL?
{
	/*
	 .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.json]) { result in
	 switch result {
	 case .success(let url):
	 // Process file URL here
	 case .failure(let error):
	 // Process error here
	 }
	 }
	 */
#if canImport(AppKit)
	let panel = NSOpenPanel()
	panel.allowsMultipleSelection = false
	panel.canChooseDirectories = true
	let openResult = panel.runModal()
	
	//	user cancelled
	if openResult == .init(rawValue: 0)
	{
		return nil
	}
	
	if openResult != .OK
	{
		throw RuntimeError("File open failed \(openResult)")
	}
	guard let filePath = panel.url else
	{
		throw RuntimeError("File opened, but no file")
	}
	return filePath
#else
	throw RuntimeError("File import not supported")
#endif
}

public func ShowInFinder(_ filePaths:[URL])
{
#if canImport(AppKit)
	NSWorkspace.shared.activateFileViewerSelecting(filePaths)
#else
	print("ShowInFinder not supported")
#endif
}
