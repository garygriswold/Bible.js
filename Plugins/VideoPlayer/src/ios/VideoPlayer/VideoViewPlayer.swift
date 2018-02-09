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
    private let delegate = VideoViewControllerDelegate() // Without this delegate is lost because weak to controller
    
    let videoAnalytics: VideoAnalytics
    let currentState: VideoViewState // To help prevent GC
    
    public init(mediaSource: String,
                videoId: String,
                languageId: String,
                silLang: String,
                videoUrl: String) {
	    print("INSIDE VideoViewPlayer \(videoId)  \(videoUrl)")
		self.currentState = VideoViewState.retrieve(videoId: videoId)
        self.currentState.videoUrl = videoUrl
        self.videoAnalytics = VideoAnalytics(mediaSource: mediaSource,
                                        mediaId: videoId,
                                        languageId: languageId,
                                        silLang: silLang)
    }
    
    deinit {
        print("VideoViewPlayer is deallocated.")
    }

    public func begin(complete: @escaping (_ error:Error?) -> Void) {
        print("VideoViewPlayer.BEGIN")
        let videoUrl: URL? = URL(string: self.currentState.videoUrl)
        if let url: URL = videoUrl {
            let asset = AVAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            let seekTime = backupSeek(state: self.currentState)
            if (CMTimeGetSeconds(seekTime) > 0.1) {
                playerItem.seek(to: seekTime)
            }
            let player = AVPlayer(playerItem: playerItem)
        
            delegate.completionHandler = complete
            delegate.videoAnalytics = self.videoAnalytics
            self.controller.delegate = delegate
            self.controller.showsPlaybackControls = true
            self.controller.player = player
            self.controller.player?.play()
        }
    }
    
    func backupSeek(state: VideoViewState) -> CMTime {
		let duration: Int64 = Int64(Date().timeIntervalSince(state.timestamp))
		let backupSec: Int = String(duration).count // could multiply by a factor here
		let backupTime: CMTime = CMTimeMake(Int64(backupSec), 1)
		return(CMTimeSubtract(state.position, backupTime))
	}
}

