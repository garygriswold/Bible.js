//
//  AudioControlCenter.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 11/3/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import MediaPlayer
import WebKit

class AudioControlCenter {
    
    static let shared = AudioControlCenter()
    
    private var currentBookChapter: String
    private var info: [String: Any]
    
    private init() {
        self.currentBookChapter = ""
        self.info = [String: Any]()
    }
    
    deinit {
        print("***** Deinit AudioControlCenter *****")
    }

    func setupControlCenter(player: AudioBible) {
        let controlCenter = MPRemoteCommandCenter.shared()
        
        controlCenter.playCommand.addTarget(handler: { event in
            if !player.isPlaying() {
                player.play()
                return MPRemoteCommandHandlerStatus.success
            }
            return MPRemoteCommandHandlerStatus.commandFailed
        })
        
        controlCenter.pauseCommand.addTarget(handler: { event in
            if player.isPlaying() {
                player.pause()
                return MPRemoteCommandHandlerStatus.success
            }
            return MPRemoteCommandHandlerStatus.commandFailed
        })
        
        controlCenter.nextTrackCommand.isEnabled = false
        controlCenter.previousTrackCommand.isEnabled = false
        /*
        controlCenter.nextTrackCommand.addTarget { event in
            if player.getPlayer() != nil {
                player.nextChapter()
                return MPRemoteCommandHandlerStatus.success
            }
            return MPRemoteCommandHandlerStatus.commandFailed
        }
        
        controlCenter.previousTrackCommand.addTarget { event in
            if player.getPlayer() != nil {
                player.priorChapter()
                return MPRemoteCommandHandlerStatus.success
            }
            return MPRemoteCommandHandlerStatus.commandFailed
        }
        */
        controlCenter.skipBackwardCommand.isEnabled = true
        controlCenter.skipBackwardCommand.preferredIntervals = [10.0]
        controlCenter.skipBackwardCommand.addTarget(handler: { event in
            if player.getPlayer() != nil {
                let position = player.skip(seconds: -10)
                self.info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = position
                MPNowPlayingInfoCenter.default().nowPlayingInfo = self.info
                return MPRemoteCommandHandlerStatus.success
            }
            return MPRemoteCommandHandlerStatus.commandFailed
        })
        
        controlCenter.skipForwardCommand.isEnabled = true
        controlCenter.skipForwardCommand.preferredIntervals = [10.0]
        controlCenter.skipForwardCommand.addTarget(handler: { event in
            if player.getPlayer() != nil {
                let position = player.skip(seconds: 10)
                self.info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = position
                MPNowPlayingInfoCenter.default().nowPlayingInfo = self.info
                return MPRemoteCommandHandlerStatus.success
            }
            return MPRemoteCommandHandlerStatus.commandFailed
        })
        
        controlCenter.seekBackwardCommand.isEnabled = false
        controlCenter.seekForwardCommand.isEnabled = false
        controlCenter.bookmarkCommand.isEnabled = false
    }
    
    func nowPlaying(player: AudioBible) {
        if let reference = player.getCurrentReference() {
            if let play = player.getPlayer() {
                if let item = play.currentItem {
                    if let image = self.getIcon() {
                        info[MPMediaItemPropertyArtwork] =
                            MPMediaItemArtwork(boundsSize: image.size) { size in
                                return image
                        }
                    } else {
                        print("Error: Could not find image for Control Center.")
                    }
                    self.currentBookChapter = reference.localName
                    self.info[MPMediaItemPropertyTitle] = self.currentBookChapter
                    self.info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = item.currentTime().seconds
                    self.info[MPMediaItemPropertyPlaybackDuration] = item.asset.duration.seconds
                    self.info[MPNowPlayingInfoPropertyPlaybackRate] = play.rate
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = self.info
                    
                    self.updateTextPosition(nodeId: reference.getNodeId(verse: 0))
                }
            }
        }
    }
    
    /** This function might need be modified if the location of icons in the main App is modified. */
    private func getIcon() -> UIImage? {
        let iconName = UIApplication.shared.alternateIconName
        return (iconName != nil) ? UIImage(named: "www/icons/\(iconName!)-60.png") : nil
    }
    
    func updateNowPlaying(reference: AudioReference, verse: Int, position: Double) {
        let title = self.currentBookChapter + ":" + String(verse)
        let duration = MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration]
        let playRate = MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate]

        self.info[MPMediaItemPropertyTitle] = title
        self.info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = position
        self.info[MPMediaItemPropertyPlaybackDuration] = duration
        self.info[MPNowPlayingInfoPropertyPlaybackRate] = playRate
        MPNowPlayingInfoCenter.default().nowPlayingInfo = self.info
        
        self.updateTextPosition(nodeId: reference.getNodeId(verse: verse))
    }
    
    private func updateTextPosition(nodeId: String) {
// This must be rewritten as posting a notification to the main App, where the webview object is known.
//        if let webview = AudioBibleView.webview {
//            let msg = "document.dispatchEvent(new CustomEvent(BIBLE.SCROLL_TEXT," +
//            " { detail: { id: '\(nodeId)' }}));"
//            print("DISPATCH EVENT LISTENING TO \(nodeId)")
//            webview.evaluateJavaScript(msg, completionHandler: {(result, error) in
//                if let err = error {
//                    print("Dispatch Event Listening to: Javascript error \(err)")
//                }
//            })
//        }
    }
}
