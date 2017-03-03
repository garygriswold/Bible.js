import CoreMedia
/**
* This class persists the videoId, videoUrl and position (time) so that any video
* can be restarted from the last place that it was viewed.
*/
class VideoViewState : NSObject, NSCoding {
	
	static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
	static var currentState = VideoViewState(videoId: "jesusFilm")
	
	static func clear(videoId: String) -> Bool {
		currentState = VideoViewState(videoId: videoId)
		let archiveURL = documentsDirectory.appendingPathComponent(videoId)	
		let isSuccess = NSKeyedArchiver.archiveRootObject(currentState, toFile: archiveURL.path)
		return isSuccess		
	}
	
	static func save(videoId: String, videoUrl: String, position: CMTime) -> Bool {
		currentState = VideoViewState(videoId: videoId, videoUrl: videoUrl, position: position)
		let archiveURL = documentsDirectory.appendingPathComponent(videoId)
		let isSuccess = NSKeyedArchiver.archiveRootObject(currentState, toFile: archiveURL.path)
		return isSuccess	
	}
	
	static func update(time: CMTime?) -> Bool {
		currentState.position = ((time != nil) ? time : kCMTimeZero)!
		let archiveURL = documentsDirectory.appendingPathComponent(currentState.videoId)
		let isSuccess = NSKeyedArchiver.archiveRootObject(currentState, toFile: archiveURL.path)
		return isSuccess		
	}
	
	static func retrieve(videoId: String) -> VideoViewState {
		let archiveURL = documentsDirectory.appendingPathComponent(videoId)
		let state = NSKeyedUnarchiver.unarchiveObject(withFile: archiveURL.path) as? VideoViewState
		currentState = (state != nil) ? state! : VideoViewState(videoId: videoId)
		return currentState
	}
	
	var videoId: String
	var videoUrl: String?
	var position: CMTime
	
	init(videoId: String, videoUrl: String?, position: CMTime) {
		self.videoId = videoId
		self.videoUrl = videoUrl
		self.position = position
	}
	
	init(videoId: String) {
		self.videoId = videoId
		self.videoUrl = nil
		self.position = kCMTimeZero
	}

	required convenience init?(coder decoder: NSCoder) {
		guard let videoId = decoder.decodeObject(forKey: "videoId") as? String
		else {
			return nil
		}
		let videoUrl = decoder.decodeObject(forKey: "videoUrl") as? String
		let position = decoder.decodeTime(forKey: "position") as CMTime
		self.init(videoId: videoId, videoUrl: videoUrl, position: position)
	}
	
	func encode(with coder: NSCoder) {
    	coder.encode(self.videoId, forKey: "videoId")
		coder.encode(self.videoUrl, forKey: "videoUrl")
		coder.encode(self.position, forKey: "position")
	}
	
	func toString() -> String {
		let result = "VideoId: \(self.videoId), VideoUrl: \(self.videoUrl), Position: \(self.position)"
		return result
	}
}
