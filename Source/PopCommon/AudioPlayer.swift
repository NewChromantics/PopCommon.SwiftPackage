import SwiftUI
import AVFAudio


public class AudioPlayer : ObservableObject
{
	var AudioPlayerCache = [String:AVAudioPlayer]()
	
	func GetAudioPlayer(assetName:String,assetExtension:String) throws -> AVAudioPlayer
	{
		let key = "\(assetName).\(assetExtension)"
		if AudioPlayerCache[key] == nil
		{
			/* from asset bundle (as Data asset)
			 guard let audioData = NSDataAsset(name: "\(assetName).\(extension)")?.data else
			 {
			 throw RuntimeError("No data for asset \(assetName)")
			 }
			 let audioPlayer = try AVAudioPlayer(data: audioData)
			 */
			guard let assetUrl = Bundle.main.url(forResource: assetName, withExtension: assetExtension) else
			{
				throw RuntimeError("No data for asset \(assetName)")
			}		
			let audioPlayer = try AVAudioPlayer(contentsOf: assetUrl)
			audioPlayer.prepareToPlay()
			AudioPlayerCache[key] = audioPlayer
		}
		return AudioPlayerCache[key]!
	}
	
	public func PlayAudio(assetName:String,assetExtension:String) throws
	{
		let audioPlayer = try GetAudioPlayer( assetName: assetName, assetExtension: assetExtension )
		
		//	task seems to help with pauses... but sometimes play gets missed (AVPlayer probably not threadsafe)
		//	without, UI pauses
		//	dispatch queue does both!
		DispatchQueue.main.async
		{
			if true
			{
				//	restart sound if we trigger again
				audioPlayer.currentTime = 0
				audioPlayer.stop()
				
				//print("playing \(assetName)")
				if !audioPlayer.play() 
				{
					print("Failed to play audio \(assetName)")
					//throw RuntimeError("Failed to play audio")
				}
			}
		}
	}
	
	public func PlayRandomSound(_ filenamePrefix:String,_ range:ClosedRange<Int>,fileExtension:String="m4a")
	{
		let Wavs = range.map{ "\(filenamePrefix)\($0)" }
		let Wav = Wavs.randomElement() ?? Wavs[0]
		do
		{
			try PlayAudio(assetName:Wav,assetExtension: fileExtension)
		}
		catch
		{
			print("Failed to play audio \(error.localizedDescription)")
		}
	}
	
}

