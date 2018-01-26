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
    
    private init() {
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
            return MPRemoteCommandHandlerStatus.commandFailed // To be implemented if needed
        }
        
        controlCenter.previousTrackCommand.addTarget { event in
            return MPRemoteCommandHandlerStatus.commandFailed // To be implemented if needed
        }
    }
    
    func nowPlaying(player: AudioBible) {
        let reference = player.getCurrentReference()
        if let play = player.getPlayer() {
            if let item = play.currentItem {
                var nowPlayingInfo = [String : Any]()
                nowPlayingInfo[MPMediaItemPropertyTitle] = reference.localName
                print("Name: \(reference.localName)")
                //if let image = UIImage(named: "Images/PauseUPButton.png") {
                //    nowPlayingInfo[MPMediaItemPropertyArtwork] =
                //        MPMediaItemArtwork(boundsSize: image.size) { size in
                //            return image
                //    }
                //}
                print("Time: \(item.currentTime().seconds)")
                print("Duration: \(item.asset.duration.seconds)")
                print("Rate: \(play.rate)")
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = item.currentTime().seconds
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = item.asset.duration.seconds
                nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = play.rate
                
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
        }
    }
}
