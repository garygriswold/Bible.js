/**
* This class is the cordova native interface code that calls the VideoPlayer.
* It deliberately contains as little logic as possible so that the VideoPlayer
* can be unit tested as an XCode project.
*/

@objc(VideoPlayer) class VideoPlayer : CDVPlugin {
	
	//var window: UIWindow?
    //var videoViewController: VideoViewController = VideoViewController()
    var videoViewPlayer: VideoViewPlayer?
	
	@objc(showVideo:) func showVideo(command: CDVInvokedUrlCommand) {
		
    	var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)

		//let msg = command.arguments[0] as? String ?? "Nothing Entered"

		//if msg.characters.count > 0 {
		//	pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: msg)
		//}
		//self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
		
        //self.window = self.window ?? UIWindow()
        //self.window!.rootViewController = videoViewController
        //self.window!.makeKeyAndVisible()
        
        let videoUrl: String = "https://arc.gt/n8pwj?apiSessionId=58866003a32df1.69855658" // Jesus Film
        let seekSec: Int64 = 0
        self.videoViewPlayer = VideoViewPlayer(videoUrl: videoUrl, seekTime: seekSec)
        
        //self.viewController.view.addSubview(self.videoViewPlayer.view)
        present(self.videoVideoViewPlayer.controller, animated: true) {
        	//player.play()
        	self.videoViewPlayer.begin()
		}
        //self.videoViewPlayer.begin()
	}
}


// found in working plugin
//[self.viewController.view addSubview:moviePlayer.view];