//
//  AudioControlCenter.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 11/3/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import AVFoundation
import MediaPlayer

class AudioControlCenter {
    
    static let shared = AudioControlCenter()
    
    private init() {
    }
    
    deinit {
        print("***** Deinit AudioControlCenter *****")
    }

    func setupControlCenter(player: AVPlayer?) {  // I think this should really be AudioPlayer
        if let play = player {
            let controlCenter = MPRemoteCommandCenter.shared()
            
            //controlCenter.playCommand.addTarget { [unowned self] event in
            controlCenter.playCommand.addTarget { event in
                if play.rate == 0.0 {
                    play.play()
                    return MPRemoteCommandHandlerStatus.success
                }
                return MPRemoteCommandHandlerStatus.commandFailed
            }
            
            controlCenter.pauseCommand.addTarget { event in
                if play.rate == 1.0 {
                    play.pause()
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
    }
    
    func nowPlaying(player: AVPlayer?, reference: Reference) {
        if let play = player {
            if let item = play.currentItem {
                var nowPlayingInfo = [String : Any]()
                nowPlayingInfo[MPMediaItemPropertyTitle] = reference.localName
                if let image = UIImage(named: "lockscreen") {
                    nowPlayingInfo[MPMediaItemPropertyArtwork] =
                        MPMediaItemArtwork(boundsSize: image.size) { size in
                            return image
                    }
                }
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = item.currentTime().seconds
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = item.asset.duration.seconds
                nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = play.rate
                
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
        }
    }
}
