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
    
    private init() {
        self.currentBookChapter = ""
    }
    
    deinit {
        print("***** Deinit AudioControlCenter *****")
    }

    func setupControlCenter(player: AudioBible) {
        let controlCenter = MPRemoteCommandCenter.shared()
        
        controlCenter.playCommand.addTarget { event in
            if !player.isPlaying() {
                player.play()
                return MPRemoteCommandHandlerStatus.success
            }
            return MPRemoteCommandHandlerStatus.commandFailed
        }
        
        controlCenter.pauseCommand.addTarget { event in
            if player.isPlaying() {
                player.pause()
                return MPRemoteCommandHandlerStatus.success
            }
            return MPRemoteCommandHandlerStatus.commandFailed
        }
        
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
    }
    
    func nowPlaying(player: AudioBible) {
        if let reference = player.getCurrentReference() {
            if let play = player.getPlayer() {
                if let item = play.currentItem {
                    var info = [String : Any]()
                    self.currentBookChapter = reference.localName
                    info[MPMediaItemPropertyTitle] = self.currentBookChapter
                    info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = item.currentTime().seconds
                    info[MPMediaItemPropertyPlaybackDuration] = item.asset.duration.seconds
                    info[MPNowPlayingInfoPropertyPlaybackRate] = play.rate
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = info
                    
                    self.updateTextPosition(nodeId: reference.getNodeId(verse: 0))
                }
            }
        }
    }
    
    func updateNowPlaying(reference: AudioReference, verse: Int, position: Double) {
        var info = [String : Any]()
        let title = self.currentBookChapter + ":" + String(verse)
        let duration = MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration]
        let playRate = MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate]

        info[MPMediaItemPropertyTitle] = title
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = position
        info[MPMediaItemPropertyPlaybackDuration] = duration
        info[MPNowPlayingInfoPropertyPlaybackRate] = playRate
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        
        self.updateTextPosition(nodeId: reference.getNodeId(verse: verse))
    }
    
    private func updateTextPosition(nodeId: String) {
        if let webview = AudioBibleView.webview {
            let msg = "document.body.dispatchEvent(new CustomEvent(BIBLE.SCROLL_TEXT," +
            " { detail: { id: '\(nodeId)' }}));"
            print("DISPATCH EVENT LISTENING TO \(nodeId)")
            webview.evaluateJavaScript(msg, completionHandler: {(result, error) in
                if let err = error {
                    print("Dispatch Event Listening to: Javascript error \(err)")
                }
            })
        }
    }
}
