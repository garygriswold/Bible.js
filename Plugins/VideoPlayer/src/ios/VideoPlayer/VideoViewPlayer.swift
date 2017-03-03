/**
 *  VideoPlayer.swift
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

class VideoViewPlayer : NSObject {
	
    let controller = AVPlayerViewController()
    
    init(videoId: String, videoUrl: String) {
	    print("INSIDE VideoViewPlayer ")
	    let viewState = VideoViewState.retrieve(videoId: videoId)
	    viewState.videoUrl = videoUrl
        let url = URL(string: videoUrl)!
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        let seekTime: CMTime = viewState.position
        if (CMTimeGetSeconds(seekTime) > 0.1) {
            playerItem.seek(to: seekTime)
        }
        let player = AVPlayer(playerItem: playerItem)
        //self.controller = AVPlayerViewController()
        self.controller.showsPlaybackControls = true
        self.controller.initNotifications()
        //self.controller.initDebugNotifications()
        self.controller.player = player
        print("CONSTRUCTED")
    }
    deinit {
        self.controller.removeNotifications()
        //self.controller.removeDebugNotifications()
    }
    func begin() {
        print("VideoViewPlayer.BEGIN")
        self.controller.player?.play()
    }
}

