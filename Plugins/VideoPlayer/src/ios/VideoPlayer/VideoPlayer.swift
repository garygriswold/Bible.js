/**
* This class is the cordova native interface code that calls the VideoPlayer.
* It deliberately contains as little logic as possible so that the VideoPlayer
* can be unit tested as an XCode project.
*/

@objc(VideoPlayer) class VideoPlayer : CDVPlugin {
	
	static var instance: VideoPlayer?
	static var command: CDVInvokedUrlCommand?
	
	@objc(showVideo:) func showVideo(command: CDVInvokedUrlCommand) {
		
		VideoPlayer.instance = self
		VideoPlayer.command = command
		
		let videoId: String = command.arguments[0] as? String ?? ""
		let videoUrl: String = command.arguments[1] as? String ?? ""

        let videoViewPlayer = VideoViewPlayer(videoId: videoId, videoUrl: videoUrl)
        videoViewPlayer.begin() 
               
        self.viewController.present(videoViewPlayer.controller, animated: true)
	}
	
	static func releaseVideoPlayer(message: String?) {
		print("\n\nCALLED RELEASE VIDEO PLAYER")
		var pluginResult: CDVPluginResult
		if (message != nil) {
			pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: message)
		} else {
			pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
		}
		instance?.commandDelegate!.send(pluginResult, callbackId: command?.callbackId)
	}
	
//	func releaseVideoPlayer() {
//        print("\n****** releaseViewController in VideoViewController")
//        	if (self.videoViewPlayer != nil) {
//			self.videoViewPlayer?.controller.dismiss(animated: false)
//			self.videoViewPlayer = nil
//        }
//    }
}

