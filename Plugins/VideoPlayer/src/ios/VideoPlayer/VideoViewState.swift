import os.log

class VideoViewState : NSObject, NSCoding {
	
	static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
	
	static func clear(videoId: String) -> Bool {
		let archiveURL = documentsDirectory.appendingPathComponent(videoId)	
		let emptyState = VideoViewState(videoId: videoId)
		let isSuccess = NSKeyedArchiver.archiveRootObject(emptyState, toFile: archiveURL.path)
		return isSuccess		
	}
	
	static func save(state: VideoViewState) -> Bool {
		let archiveURL = documentsDirectory.appendingPathComponent(state.videoId)
		let isSuccess = NSKeyedArchiver.archiveRootObject(state, toFile: archiveURL.path)
		return isSuccess	
	}
	
	static func retrieve(videoId: String) -> VideoViewState? {
		let archiveURL = documentsDirectory.appendingPathComponent(videoId)
		let state = NSKeyedUnarchiver.unarchiveObject(withFile: archiveURL.path) as? VideoViewState
		return state
	}
	
	var videoId: String
	var videoUrl: String?
	var position: Int64
	
	init(videoId: String, videoUrl: String, position: Int64) {
		self.videoId = videoId
		self.videoUrl = videoUrl
		self.position = position
	}
	
	init(videoId: String) {
		self.videoId = videoId
		self.videoUrl = nil
		self.position = 0
	}

	required convenience init?(coder decoder: NSCoder) {
		guard let videoId = decoder.decodeObject(forKey: "videoId") as? String,
			let videoUrl = decoder.decodeObject(forKey: "videoUrl") as? String,
			let position = decoder.decodeInt64(forKey: "position") as? Int64
		else {
			return nil
		}
		self.init(videoId: videoId, videoUrl: videoUrl, position: position)
	}
	
	func encode(with coder: NSCoder) {
    	coder.encode(self.videoId, forKey: "videoId")
		coder.encode(self.videoUrl, forKey: "videoUrl")
		coder.encode(self.position, forKey: "position")		
	}
	
	func toString() -> String {
		//let result = "VideoId: " + self.videoId + ", VideoUrl: " + self.videoUrl + ", Position: " + self.position
		let result = "VideoId: \(self.videoId), VideoUrl: \(self.videoUrl), Position: \(self.position)"
		return result
	}
}




