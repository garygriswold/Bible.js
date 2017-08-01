//
//  BibleReader.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 7/31/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import Foundation
import AVFoundation

public class BibleReader : NSObject {
    
    var path: String?
    var player: AVPlayer?
    
    init(audioFile: String) {
        self.path = audioFile
        if (self.path != nil) {
        } else {
            print("Unknown path \(audioFile)")
        }
    }
    
    deinit {
        if self.player != nil {
            self.player = nil
        }
        self.removeNotifications()
        print("Deinit BibleReader")
    }
    
    public func begin() {
        print("BibleReader.BEGIN")
        if (self.path != nil) {
            let videoUrl: URL? = URL(string: self.path!)
            if let url: URL = videoUrl {
                let asset = AVAsset(url: url)
                let playerItem = AVPlayerItem(asset: asset)
                
                //let seekTime = backupSeek(state: self.currentState)
                //if (CMTimeGetSeconds(seekTime) > 0.1) {
                //    playerItem.seek(to: seekTime)
                //}
                self.player = AVPlayer(playerItem: playerItem)
                self.player?.actionAtItemEnd = AVPlayerActionAtItemEnd.pause // can be .advance
                self.initNotifications()
            
                //delegate.completionHandler = complete
                //delegate.videoAnalytics = self.videoAnalytics
                //self.controller.delegate = delegate
            }
        }
    }

    
    func play() {
        self.player?.play()
        print("Play Status = \(String(describing: self.player?.status))")
    }
    
    func pause() {
        self.player?.pause()
        print("Pause Status = \(String(describing: self.player?.status))")
    }
    
    func initNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidPlayToEndTime(note:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemFailedToPlayToEndTime(note:)),
                                               name: .AVPlayerItemFailedToPlayToEndTime,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemPlaybackStalled(note:)),
                                               name: .AVPlayerItemPlaybackStalled,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemNewErrorLogEntry(note:)),
                                               name: .AVPlayerItemNewErrorLogEntry,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillResignActive(note:)),
                                               name: .UIApplicationWillResignActive,
                                               object: nil)
    }

    func removeNotifications() {
        print("\n ***** INSIDE REMOVE NOTIFICATIONS")
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemPlaybackStalled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemNewErrorLogEntry, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive, object: nil)
    }
    
    func playerItemDidPlayToEndTime(note:Notification) {
        print("\n** DID PLAY TO END \(String(describing: note.object))")
        //self.dismiss(animated: false) // move this till after??
        //sendVideoAnalytics(isStart: false, isDone: true)
        //VideoViewState.clear()
    }
    func playerItemFailedToPlayToEndTime(note:Notification) {
        print("\n********* FAILED TO PLAY TO END *********\(String(describing: note.object))")
    }
    func playerItemPlaybackStalled(note:Notification) {
        print("\n****** PLAYBACK STALLED \(String(describing: note.object))")
    }
    func playerItemNewErrorLogEntry(note:Notification) {
        print("\n****** ERROR LOG ENTRY \(String(describing: note.object))\n\(String(describing: self.player?.currentItem?.errorLog()))")
    }
    /**
     * This method is called when the Home button is clicked or double clicked.
     * VideoState is saved in this method
     */
    func applicationWillResignActive(note:Notification) {
        print("\n******* APPLICATION WILL RESIGN ACTIVE *** in AVPlayerViewController")
        //sendVideoAnalytics(isStart: false, isDone: false)
        //VideoViewState.update(time: self.player?.currentTime())
    }
}


/*
 
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
    let backupSec: Int = String(duration).characters.count // could multiply by a factor here
    let backupTime: CMTime = CMTimeMake(Int64(backupSec), 1)
    return(CMTimeSubtract(state.position, backupTime))
 }
}

 
*/

