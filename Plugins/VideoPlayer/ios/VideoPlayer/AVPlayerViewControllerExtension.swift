//
//  AVPlayerViewControllerExtension.swift
//  VideoPlayer
//
//  Created by Gary Griswold on 1/27/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//
import AVKit

extension AVPlayerViewController {
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.landscapeRight
    }
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    override open func viewWillDisappear(_ animated: Bool) {
        print("\n********** VIEW WILL DISAPPEAR ***** in AVPlayerViewController")
        super.viewWillDisappear(animated)
        (self.presentingViewController as! ViewController).releaseVideoPlayer()
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
                                               selector: #selector(playerItemTimeJumped(note:)),
                                               name: .AVPlayerItemTimeJumped,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemPlaybackStalled(note:)),
                                               name: .AVPlayerItemPlaybackStalled,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemNewAccessLogEntry(note:)),
                                               name: .AVPlayerItemNewAccessLogEntry,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemNewErrorLogEntry(note:)),
                                               name: .AVPlayerItemNewErrorLogEntry,
                                               object: nil)
    }
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemTimeJumped, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemPlaybackStalled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemNewAccessLogEntry, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemNewErrorLogEntry, object: nil)
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
    /*
     override open func observeValue(forKeyPath keyPath: String?,
     of object: Any?,
     change: [NSKeyValueChangeKey : Any]?,
     context: UnsafeMutableRawPointer?) {
     //super.observeValue(forKeyPath keyPath: keyPath, of: object, change: change, context: context)
     //        print("Inside KO observer, \(keyPath)  \(change?[.oldKey])  \(change?[.newKey])")
     guard context == &playerItemContext else {
     super.observeValue(forKeyPath: keyPath,
     of: object,
     change: change,
     context: context)
     return
     }
     if keyPath == #keyPath(AVPlayerItem.status) {
     let status: AVPlayerItemStatus
     if let statusNumber = change?[.newKey] as? NSNumber {
     status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
     } else {
     status = .unknown
     }
     print("STATUS SET \(status)")
     switch status {
     case .readyToPlay:
     print("ITEM STATUS is readyToPlay")
     case .failed:
     print("ITEM STATUS is failed")
     case .unknown:
     print("ITEM STATUS is unknown")
     }
     }
     }
     */
}


