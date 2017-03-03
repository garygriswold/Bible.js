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
    var videoUrl: String
    var position: CMTime
    
    init(videoId: String, videoUrl: String) {
	    print("INSIDE VideoViewPlayer ")
	    let viewState = VideoViewState.retrieve(videoId: videoId)
	    VideoViewState.currentState.videoUrl = videoUrl
	    self.videoUrl = videoUrl
	    self.position = viewState.position
        self.controller.initNotifications()
        //self.controller.initDebugNotifications()
        print("CONSTRUCTED")
    }

    func begin() {
        print("VideoViewPlayer.BEGIN")
        
        let url = URL(string: self.videoUrl)!
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        if (CMTimeGetSeconds(self.position) > 0.1) {
            playerItem.seek(to: self.position)
        }
        let player = AVPlayer(playerItem: playerItem)
        self.controller.showsPlaybackControls = true
        self.controller.player = player
        self.controller.player?.play()
    }
}

