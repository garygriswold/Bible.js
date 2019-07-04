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
    
    private init() {
    }
    
    deinit {
        print("***** Deinit AudioControlCenter *****")
    }

    func setupControlCenter(player: AudioBible) {
        //print("Called setup Control Center \(player.getCurrentReference())")
        let controlCenter = MPRemoteCommandCenter.shared()
        
        controlCenter.playCommand.isEnabled = true
        controlCenter.playCommand.addTarget(handler: { event in
            if !player.isPlaying() {
                player.play()
                MPNowPlayingInfoCenter.default().playbackState = .playing
                return MPRemoteCommandHandlerStatus.success
            }
            return MPRemoteCommandHandlerStatus.commandFailed
        })
        
        controlCenter.pauseCommand.isEnabled = true
        controlCenter.pauseCommand.addTarget(handler: { event in
            if player.isPlaying() {
                player.pause()
                MPNowPlayingInfoCenter.default().playbackState = .paused
                return MPRemoteCommandHandlerStatus.success
            }
            return MPRemoteCommandHandlerStatus.commandFailed
        })
        
        controlCenter.nextTrackCommand.isEnabled = true
        controlCenter.nextTrackCommand.addTarget(handler: { event in
            if player.getPlayer() != nil {
                player.nextChapter()
                MPNowPlayingInfoCenter.default().playbackState = .playing
                return MPRemoteCommandHandlerStatus.success
            }
            return MPRemoteCommandHandlerStatus.commandFailed
        })
        
        controlCenter.previousTrackCommand.isEnabled = false // turned of so that skip back appears
        controlCenter.previousTrackCommand.addTarget(handler: { event in
            if player.getPlayer() != nil {
                player.priorChapter()
                MPNowPlayingInfoCenter.default().playbackState = .playing
                return MPRemoteCommandHandlerStatus.success
            }
            return MPRemoteCommandHandlerStatus.commandFailed
        })
        
        controlCenter.skipBackwardCommand.isEnabled = true
        controlCenter.skipBackwardCommand.preferredIntervals = [10.0]
        controlCenter.skipBackwardCommand.addTarget(handler: { event in
            if player.getPlayer() != nil {
                player.skip(seconds: -10)
                // .playbackState is unchanged
                return MPRemoteCommandHandlerStatus.success
            }
            return MPRemoteCommandHandlerStatus.commandFailed
        })
        
        controlCenter.skipForwardCommand.isEnabled = false // turned of so that next chapter appears
        controlCenter.skipForwardCommand.preferredIntervals = [10.0]
        controlCenter.skipForwardCommand.addTarget(handler: { event in
            if player.getPlayer() != nil {
                player.skip(seconds: 10)
                // .playbackState is unchanged
                return MPRemoteCommandHandlerStatus.success
            }
            return MPRemoteCommandHandlerStatus.commandFailed
        })
        
        controlCenter.togglePlayPauseCommand.isEnabled = false
        controlCenter.stopCommand.isEnabled = false
        controlCenter.changePlaybackPositionCommand.isEnabled = false
        controlCenter.changeRepeatModeCommand.isEnabled = false
        controlCenter.changeShuffleModeCommand.isEnabled = false
        controlCenter.changePlaybackRateCommand.isEnabled = false
        controlCenter.seekBackwardCommand.isEnabled = false
        controlCenter.seekForwardCommand.isEnabled = false
        controlCenter.ratingCommand.isEnabled = false
        controlCenter.likeCommand.isEnabled = false
        controlCenter.dislikeCommand.isEnabled = false
        controlCenter.bookmarkCommand.isEnabled = false
        controlCenter.enableLanguageOptionCommand.isEnabled = false
        controlCenter.disableLanguageOptionCommand.isEnabled = false
    }
    
    func nowPlaying(player: AudioBible) {
        //print("Called now Playing \(player.getCurrentReference())")
        if let reference = player.getCurrentReference() {
            if let play = player.getPlayer() {
                if let item = play.currentItem {
                    
                    var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()
                    
                    info[MPNowPlayingInfoCollectionIdentifier] = reference.damId
                    info[MPNowPlayingInfoPropertyMediaType] = MPMediaType.audioBook.rawValue
                    info[MPNowPlayingInfoPropertyIsLiveStream] = 0.0 // 0.0 is false
                    info[MPMediaItemPropertyTitle] = reference.localName
                    info[MPMediaItemPropertyAlbumTitle] = reference.bibleName
                    // Title \n Artist - Album Title
                    
                    info[MPMediaItemPropertyPlaybackDuration] = item.asset.duration.seconds
                    info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = item.currentTime().seconds
                    info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
                    info[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1.0
   
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = info
                    
                    self.getIcon()
                    
                    self.updateTextPosition(nodeId: reference.getNodeId(verse: 0))
                }
            }
        }
    }
    
    /** This function might need be modified if the location of icons in the main App is modified. */
    private func getIcon() {
        DispatchQueue.main.async {
            print("Get image in main thread")
            if let iconName = UIApplication.shared.alternateIconName {
                if let image = UIImage(named: "www/icons/\(iconName)-60.png") {
                    MPNowPlayingInfoCenter.default().nowPlayingInfo![MPMediaItemPropertyArtwork] =
                        MPMediaItemArtwork(boundsSize: image.size) { size in
                            return image
                    }
                }
            }
        }
    }
    
    /* This is called by AudioBibleView */
    func updateNowPlaying(reference: AudioReference, verse: Int, position: Double) {
        print("Update now Playing Reference \(reference) : \(verse) \(position)")
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()
        info[MPMediaItemPropertyTitle] = reference.localName + ":" + String(verse)
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = position
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        
        self.updateTextPosition(nodeId: reference.getNodeId(verse: verse))
    }
    
    func updateNowPlaying(position: Double) {
        print("Update now Playing position: \(position)")
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = position
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
