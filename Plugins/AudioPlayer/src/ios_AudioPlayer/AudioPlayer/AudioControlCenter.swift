//
//  AudioControlCenter.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 11/3/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import MediaPlayer

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
            if player.isPlaying() {
                player.nextChapter()
                return MPRemoteCommandHandlerStatus.success
            }
            return MPRemoteCommandHandlerStatus.commandFailed
        }
        
        controlCenter.previousTrackCommand.addTarget { event in
            if player.isPlaying() {
                player.priorChapter()
                return MPRemoteCommandHandlerStatus.success
            }
            return MPRemoteCommandHandlerStatus.commandFailed
        }
    }
    
    func nowPlaying(player: AudioBible) {
        let reference = player.getCurrentReference()
        if let play = player.getPlayer() {
            if let item = play.currentItem {
                var info = [String : Any]()
                self.currentBookChapter = reference.localName
                info[MPMediaItemPropertyTitle] = self.currentBookChapter
                //if let image = UIImage(named: "Images/Logo80.png") {
                //    info[MPMediaItemPropertyArtwork] =
                //        MPMediaItemArtwork(boundsSize: image.size) { size in
                //            return image
                //    }
                //}
                info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = item.currentTime().seconds
                info[MPMediaItemPropertyPlaybackDuration] = item.asset.duration.seconds
                info[MPNowPlayingInfoPropertyPlaybackRate] = play.rate
                MPNowPlayingInfoCenter.default().nowPlayingInfo = info
            }
        }
    }
    
    func updateNowPlaying(verse: Int, position: Double) {
        var info = [String : Any]()
        let title = self.currentBookChapter + ":" + String(verse)
        let duration = MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration]
        let playRate = MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate]

        info[MPMediaItemPropertyTitle] = title
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = position
        info[MPMediaItemPropertyPlaybackDuration] = duration
        info[MPNowPlayingInfoPropertyPlaybackRate] = playRate
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}
