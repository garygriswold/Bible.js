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
	
	@objc(present:) func present(command: CDVInvokedUrlCommand) {
        AwsS3.region = "us-east-1"
        let audioController = AudioBibleController.shared
		audioController.present(
			view: self.webView,
			version: command.arguments[0] as? String ?? "",
			silLang: command.arguments[1] as? String ?? "",
			book: command.arguments[2] as? String ?? "",
			chapterNum: command.arguments[3] as? Int ?? 1,
			fileType: command.arguments[4] as? String ?? "",
			complete: { error in
				var result: CDVPluginResult
				if let err = error {
		        	result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: err.localizedDescription)
				} else {
		        	result = CDVPluginResult(status: CDVCommandStatus_OK)
				}
				self.commandDelegate!.send(result, callbackId: command.callbackId)
			}
		)
	}
}



