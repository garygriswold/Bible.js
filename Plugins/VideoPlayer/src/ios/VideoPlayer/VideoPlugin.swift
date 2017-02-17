/**
* This class is the cordova native interface code that calls the VideoPlayer.
* It deliberately contains as little logic as possible so that the VideoPlayer
* can be unit tested as an XCode project.
*/

@objc(VideoPlugin) class VideoPlugin : CDVPlugin {
	
	var window: UIWindow?
    var videoViewController: VideoViewController = VideoViewController()
	
	@objc(present:) func present(command: CDVInvokedUrlCommand) {
		
    	var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)

		//let msg = command.arguments[0] as? String ?? "Nothing Entered"

		//if msg.characters.count > 0 {
		//	pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: msg)
		//}
		//self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
		
        self.window = self.window ?? UIWindow()
        self.window!.rootViewController = videoViewController
        self.window!.makeKeyAndVisible()
	}
}


// found in working plugin
//[self.viewController.view addSubview:moviePlayer.view];