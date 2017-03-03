/**
* This class is the cordova native interface code that calls the VideoPlayer.
* It deliberately contains as little logic as possible so that the VideoPlayer
* can be unit tested as an XCode project.
*/

@objc(VideoPlayer) class VideoPlayer : CDVPlugin {
	
    var videoViewPlayer: VideoViewPlayer?
	
	@objc(showVideo:) func showVideo(command: CDVInvokedUrlCommand) {
		
    	//var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
		
		let videoId: String = command.arguments[0] as? String ?? ""
		let videoUrl: String = command.arguments[1] as? String ?? ""

        self.videoViewPlayer = VideoViewPlayer(videoId: videoId, videoUrl: videoUrl)
        
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


//// There is no callback yet, and I don't this release is ever called.
