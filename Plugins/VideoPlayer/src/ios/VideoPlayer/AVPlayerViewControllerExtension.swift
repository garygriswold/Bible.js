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
import Utility

extension AVPlayerViewController {
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.landscapeRight
    }
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("\n********** VIEW DID APPEAR ***** in AVPlayerViewController \(animated)")
        sendVideoAnalytics(isStart: true, isDone: false)
        
        // Init notifications after analytics is started so that it does not get any false ends.
        initNotifications()
        //initDebugNotifications()
    }
    /**
    * This method is called when the Done button on the video player is clicked.
    * Video State is saved in this method.
    */
    override open func viewDidDisappear(_ animated: Bool) {
	    super.viewDidDisappear(animated)
        print("\n********** VIEW DID DISAPPEAR ***** in AVPlayerViewController \(animated)")

        sendVideoAnalytics(isStart: false, isDone: false)
        if let position = self.player?.currentTime() {
            MediaPlayState.video.update(position: position)
        }
        releaseVideoPlayer()
    }
    override open func didReceiveMemoryWarning() {
	    super.didReceiveMemoryWarning()
	    print("\n*********** DID RECEIVE MEMORY WARNING **** in AVPlayerViewController")
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
	    print("\n ***** INSIDE REMOVE NOTIFICATIONS")
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
    @objc func playerItemDidPlayToEndTime(note:Notification) {
        print("\n** DID PLAY TO END \(String(describing: note.object))")
        self.dismiss(animated: false) // move this till after??
        sendVideoAnalytics(isStart: false, isDone: true)
        MediaPlayState.video.delete()
    }
    @objc func playerItemFailedToPlayToEndTime(note:Notification) {
        print("\n********* FAILED TO PLAY TO END *********\(String(describing: note.object))")
    }
    @objc func playerItemTimeJumped(note:Notification) {
        print("\n****** TIME JUMPED \(String(describing: note.object))")
    }
    @objc func playerItemPlaybackStalled(note:Notification) {
        print("\n****** PLAYBACK STALLED \(String(describing: note.object))")
    }
    @objc func playerItemNewAccessLogEntry(note:Notification) {
        print("\n****** ACCESS LOG ENTRY \(String(describing: note.object))\n\(String(describing: self.player?.currentItem?.accessLog()))")
    }
    @objc func playerItemNewErrorLogEntry(note:Notification) {
        print("\n****** ERROR LOG ENTRY \(String(describing: note.object))\n\(String(describing: self.player?.currentItem?.errorLog()))")
    }
    /**
    * This method is called when the Home button is clicked or double clicked.
    * VideoState is saved in this method
    */
    @objc func applicationWillResignActive(note:Notification) {
	    print("\n******* APPLICATION WILL RESIGN ACTIVE *** in AVPlayerViewController")
        sendVideoAnalytics(isStart: false, isDone: false)
        if let position = self.player?.currentTime() {
            MediaPlayState.video.update(position: position)
        }
    }
    private func releaseVideoPlayer() {
        print("\n******* INSIDE RELEASE PLAYER ")
        removeNotifications()
        removeDebugNotifications()
        if (self.delegate != nil) {
            let videoDelegate = self.delegate as? VideoViewControllerDelegate
            videoDelegate?.completionHandler?(nil)
        }
    }
    private func sendVideoAnalytics(isStart: Bool, isDone: Bool) {
        print("\n*********** INSIDE SAVE ANALYTICS \(isDone)")
        let currTime = (self.player != nil) ? self.player!.currentTime() : kCMTimeZero
        if (self.delegate != nil) {
            let videoDelegate = self.delegate as? VideoViewControllerDelegate
            if (isStart) {
                videoDelegate?.videoAnalytics?.playStarted(position: currTime)
            } else {
                videoDelegate?.videoAnalytics?.playEnded(position: currTime, completed: isDone)
                videoDelegate?.videoAnalytics = nil // prevent sending duplicate messages
            }
        }
    }
}


