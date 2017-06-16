/**
 *  VideoViewPlayer.swift
 *
 *  Created by Gary Griswold on 1/16/17.
 *  Copyright © 2017 ShortSands. All rights reserved.
 *  Created by garygriswold on 1/26/17.
 *  This is based up the following plugin:
 *  https://github.com/nchutchind/cordova-plugin-streaming-media
 */
import AVFoundation
import AVKit
import CoreMedia

public class VideoViewPlayer : NSObject {
	
    public let controller = AVPlayerViewController()
    
    public init(videoId: String, videoUrl: String) {
	    print("INSIDE VideoViewPlayer \(videoId)  \(videoUrl)")
		VideoViewState.retrieve(videoId: videoId)
		VideoViewState.currentState.videoUrl = videoUrl
        self.controller.initNotifications()
        //self.controller.initDebugNotifications()
        print("CONSTRUCTED")
    }

    //public func begin() {
    public func begin(complete: @escaping (_ error:Error?) -> Void) {
        print("VideoViewPlayer.BEGIN")
        let url = URL(string: VideoViewState.currentState.videoUrl!)!
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        let seekTime = backupSeek(state: VideoViewState.currentState)
        if (CMTimeGetSeconds(seekTime) > 0.1) {
            playerItem.seek(to: seekTime)
        }
        let player = AVPlayer(playerItem: playerItem)
        
        let delegate = VideoViewControllerDelegate()
        delegate.completionHandler = complete
        self.controller.delegate = delegate
        self.controller.showsPlaybackControls = true
        self.controller.player = player
        self.controller.player?.play()
    }
    
    func backupSeek(state: VideoViewState) -> CMTime {
		let duration: Int64 = Int64(Date().timeIntervalSince(state.timestamp))
		let backupSec: Int = String(duration).characters.count // could multiply by a factor here
		let backupTime: CMTime = CMTimeMake(Int64(backupSec), 1)
		return(CMTimeSubtract(state.position, backupTime))
	}
}

