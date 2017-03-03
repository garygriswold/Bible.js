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
    override open func viewDidDisappear(_ animated: Bool) {
        print("\n********** VIEW DID DISAPPEAR ***** in AVPlayerViewController")
        super.viewDidDisappear(animated)
        
        VideoViewState.update(time: self.player?.currentTime())
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
    func playerItemDidPlayToEndTime(note:Notification) {
        print("\n** DID PLAY TO END \(note.object)")
        self.dismiss(animated: false)
        
        VideoViewState.clear()
    }
    func playerItemFailedToPlayToEndTime(note:Notification) {
        print("\n********* FAILED TO PLAY TO END *********\(note.object)")
    }
    func playerItemTimeJumped(note:Notification) {
        print("\n****** TIME JUMPED \(note.object)")
    }
    func playerItemPlaybackStalled(note:Notification) {
        print("\n****** PLAYBACK STALLED \(note.object)")
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
    private func releaseVideoPlayer() {
        removeNotifications()
        removeDebugNotifications()	
        
        //print("SELF CONTROLLER \(String(describing: type(of: self))")        
        //print("PARENT CONTROLLER \(String(describing: type(of: self.presentingViewController))")    
    }
}


