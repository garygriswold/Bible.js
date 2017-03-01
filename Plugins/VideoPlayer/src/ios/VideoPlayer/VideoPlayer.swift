/**
* This class is the cordova native interface code that calls the VideoPlayer.
* It deliberately contains as little logic as possible so that the VideoPlayer
* can be unit tested as an XCode project.
*/

@objc(VideoPlayer) class VideoPlayer : CDVPlugin {
	
    var videoViewPlayer: VideoViewPlayer?
	
	@objc(showVideo:) func showVideo(command: CDVInvokedUrlCommand) {
		
    	//var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)

		//let msg = command.arguments[0] as? String ?? "Nothing Entered"
		
		let videoId: String = command.arguments[0] as? String ?? ""
		let videoUrl: String = command.arguments[1] as? String ?? ""

        
//        let videoUrl: String = "https://arc.gt/n8pwj?apiSessionId=58866003a32df1.69855658" // Jesus Film
        let seekSec: Int64 = 0
        self.videoViewPlayer = VideoViewPlayer(videoUrl: videoUrl, seekTime: seekSec)
        
        self.viewController.present(self.videoViewPlayer!.controller, animated: true)
        self.videoViewPlayer!.begin()
	}
	
	func releaseVideoPlayer() {
        print("\n****** releaseViewController in VideoViewController")
        	if (self.videoViewPlayer != nil) {
			self.videoViewPlayer?.controller.dismiss(animated: false)
			self.videoViewPlayer = nil
        }
    }
}
