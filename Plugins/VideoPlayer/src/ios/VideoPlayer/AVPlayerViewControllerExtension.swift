/**
 *  AVPlayerViewControllerExtension.swift
 *  VideoPlayer
 *
 *  Created by Gary Griswold on 1/27/17.
 *  Copyright © 2017 ShortSands. All rights reserved.
 */
import AVKit
import UIKit
import CoreMedia

extension AVPlayerViewController {
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.landscapeRight
    }
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    /**
    * This method is called when the Done button on the video player is clicked.
    * Video State is saved in this method.
    */
    override open func viewWillDisappear(_ animated: Bool) {
        print("\n********** VIEW WILL DISAPPEAR ***** in AVPlayerViewController")
        super.viewWillDisappear(animated)
        //(self.presentingViewController as! VideoViewController).releaseVideoPlayer()
        /// Can I somehow call VideoPlayer here in order to do this release?
        
        VideoViewState.update(time: self.player?.currentTime())
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
    func initDebugNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemNewAccessLogEntry(note:)),
                                               name: .AVPlayerItemNewAccessLogEntry,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemTimeJumped(note:)),
                                               name: .AVPlayerItemTimeJumped,
                                               object: nil)   
    }
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemPlaybackStalled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemNewErrorLogEntry, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive, object: nil)
    }
    func removeDebugNotifications() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemNewAccessLogEntry, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemTimeJumped, object: nil)    
    }
    func playerItemDidPlayToEndTime(note:Notification) {
        print("\n** DID PLAY TO END \(note.object)")
        // .name, object.AVPlayerItem, object.asset.AVURLAsset, object.asset.URL
        self.dismiss(animated: false)
    }
    func playerItemFailedToPlayToEndTime(note:Notification) {
        print("\n********* FAILED TO PLAY TO END *********\(note.object)")
    }
    func playerItemTimeJumped(note:Notification) {
        print("\n****** TIME JUMPED \(note.object)")
    }
    func playerItemPlaybackStalled(note:Notification) {
        print("\n****** PLAYBACK STALLED \(note.object)")
        // .name, object.AVPlayerItem, object.asset.AVURLAsset, object.asset.URL
    }
    func playerItemNewAccessLogEntry(note:Notification) {
        // did not start is not reported here
        print("\n****** ACCESS LOG ENTRY \(note.object)\n\(self.player?.currentItem?.accessLog())")
    }
    func playerItemNewErrorLogEntry(note:Notification) {
        print("\n****** ERROR LOG ENTRY \(note.object)\n\(self.player?.currentItem?.errorLog())")
    }
    /**
    * This method is called when the Home button is clicked or double clicked.
    * VideoState is saved in this method
    */
    func applicationWillResignActive(note:Notification) {
	    print("\n******* APPLICATION WILL RESIGN ACTIVE *** in AVPlayerViewController")
	    VideoViewState.update(time: self.player?.currentTime())
    }
}


