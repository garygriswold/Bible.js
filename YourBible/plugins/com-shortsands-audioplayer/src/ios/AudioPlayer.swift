/**
* This class is the cordova native interface code that calls the AudioPlayer.
* It deliberately contains as little logic as possible so that the AudioPlayer
* can be unit tested as an XCode project.
* 
* Calls:
* func present(view: UIView, version: String, silLang: String, book: String, chapter: String, fileType: String)
* Returns:
* func playHasStopped()
*/

@objc(AudioPlayer) class AudioPlayer : CDVPlugin {
    
    @objc(findAudioVersion:) func findAudioVersion(command: CDVInvokedUrlCommand) {
        AwsS3.region = "us-east-1"
        let audioController = AudioBibleController.shared
        audioController.findAudioVersion(
            version: command.arguments[0] as? String ?? "",
            silLang: command.arguments[1] as? String ?? "",
            complete: { bookIdList in
                let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: bookIdList)
                self.commandDelegate!.send(result, callbackId: command.callbackId)
            }
        )
    }
    
    @objc(isPlaying:) func isPlaying(command: CDVInvokedUrlCommand) {
        let audioController = AudioBibleController.shared
        let message:String = (audioController.isPlaying()) ? "T" : "F"
        let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: message)
        self.commandDelegate!.send(result, callbackId: command.callbackId)
    }
	
	@objc(present:) func present(command: CDVInvokedUrlCommand) {
        AwsS3.region = "us-east-1"
        let audioController = AudioBibleController.shared
		audioController.present(
			view: self.webView,
			book: command.arguments[0] as? String ?? "",
			chapterNum: command.arguments[1] as? Int ?? 1,
			complete: { error in
                // No error is being returned.
				let result = CDVPluginResult(status: CDVCommandStatus_OK)
				self.commandDelegate!.send(result, callbackId: command.callbackId)
            }
		)
	}
    
    @objc(stop:) func stop(command: CDVInvokedUrlCommand) {
        let audioController = AudioBibleController.shared
        audioController.stop()
        let result = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate!.send(result, callbackId: command.callbackId)
    }
}



