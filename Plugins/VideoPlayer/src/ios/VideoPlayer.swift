/**
* This class is the cordova native interface code that calls the VideoPlayer.
* It deliberately contains as little logic as possible so that the VideoPlayer
* can be unit tested as an XCode project.
*/
import VideoPlayer

@objc(VideoPlayer) class VideoPlayer : CDVPlugin {
	
	@objc(showVideo:) func showVideo(command: CDVInvokedUrlCommand) {
		
		let videoId: String = command.arguments[0] as? String ?? ""
		let videoUrl: String = command.arguments[1] as? String ?? ""

        let videoViewPlayer = VideoViewPlayer(videoId: videoId, videoUrl: videoUrl)
        videoViewPlayer.begin(complete: { error in
            var result: CDVPluginResult
            if let err = error {
	            result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: err.localizedDescription)
            } else {
	            result = CDVPluginResult(status: CDVCommandStatus_OK)
            }
            self.commandDelegate!.send(result, callbackId: command.callbackId)
		})     
        self.viewController.present(videoViewPlayer.controller, animated: true)
	}
}

