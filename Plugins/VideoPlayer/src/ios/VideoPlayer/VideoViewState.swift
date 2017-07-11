import CoreMedia
/**
* This class persists the videoId, videoUrl and position (time) so that any video
* can be restarted from the last place that it was viewed.
*/
class VideoViewState : NSObject, NSCoding {
	
	static let directory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
	static var currentState = VideoViewState(videoId: "jesusFilm")
	
	static func retrieve(videoId: String) -> VideoViewState {
        print("INSIDE RETRIEVE \(directory)")
		let archiveURL = directory.appendingPathComponent(videoId)
		let state = NSKeyedUnarchiver.unarchiveObject(withFile: archiveURL.path) as? VideoViewState
		currentState = (state != nil) ? state! : VideoViewState(videoId: videoId)
		return currentState
	}
	
	static func clear() {
		currentState.videoUrl = ""
		currentState.position = kCMTimeZero
		currentState.timestamp = Date()
		let archiveURL = directory.appendingPathComponent(currentState.videoId)
		NSKeyedArchiver.archiveRootObject(currentState, toFile: archiveURL.path)		
	}
	
	/**
	* Clear sets videoUrl to nil, and update must not store the state after videoUrl has been set to blank
	* This is needed because the update is called after the clear when a video completes.
	*/
	static func update(time: CMTime?) {
		if (currentState.videoUrl != "") {
			currentState.position = ((time != nil) ? time : kCMTimeZero)!
			currentState.timestamp = Date()
			let archiveURL = directory.appendingPathComponent(currentState.videoId)
			NSKeyedArchiver.archiveRootObject(currentState, toFile: archiveURL.path)
		}
	}
	
	var videoId: String
	var videoUrl: String
	var position: CMTime
	var timestamp: Date
	
	init(videoId: String, videoUrl: String, position: CMTime, timestamp: Date) {
		self.videoId = videoId
		self.videoUrl = videoUrl
		self.position = position
		self.timestamp = timestamp
	}
	
	init(videoId: String) {
		self.videoId = videoId
		self.videoUrl = ""
		self.position = kCMTimeZero
		self.timestamp = Date()
	}
    
    deinit {
        print("VideoViewState is deallocated.")
    }

	required convenience init?(coder decoder: NSCoder) {
		guard let videoId = decoder.decodeObject(forKey: "videoId") as? String
		else {
			return nil
		}
		let videoUrl = decoder.decodeObject(forKey: "videoUrl") as? String ?? ""
		let position = decoder.decodeTime(forKey: "position") as CMTime
		let timestamp = decoder.decodeObject(forKey: "timestamp") as? Date ?? Date()
		self.init(videoId: videoId, videoUrl: videoUrl, position: position, timestamp: timestamp)
	}
	
	func encode(with coder: NSCoder) {
    	coder.encode(self.videoId, forKey: "videoId")
		coder.encode(self.videoUrl, forKey: "videoUrl")
		coder.encode(self.position, forKey: "position")
		coder.encode(self.timestamp, forKey: "timestamp")
	}
	
	func toString() -> String {
        let result = "VideoId: \(self.videoId), VideoUrl: \(self.videoUrl)," +
                " Position: \(self.position), Timestamp: \(self.timestamp)"
		return result
	}
}
