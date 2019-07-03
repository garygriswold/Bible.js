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
        
        controlCenter.previousTrackCommand.isEnabled = true
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
        
        controlCenter.skipForwardCommand.isEnabled = true
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
        if let reference = player.getCurrentReference() {
            if let play = player.getPlayer() {
                if let item = play.currentItem {
                    
                    var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()
                //https://developer.apple.com/documentation/mediaplayer/mpmediaitem/general_media_item_property_keys
                    // The above crashes App
                    //self.info[MPMediaItemPropertyMediaType] = MPMediaType.audioBook
                    info[MPMediaItemPropertyPodcastTitle] = "Podcast Title" // necessary?
                    self.currentBookChapter = reference.localName
                    print("Title \(self.currentBookChapter)")
                    info[MPMediaItemPropertyTitle] = self.currentBookChapter
                    info[MPMediaItemPropertyAlbumTitle] = reference.bibleName
                    // Title \n Artist - Album Title
                    
                    //https://developer.apple.com/documentation/mediaplayer/mpnowplayinginfocenter
                    info[MPMediaItemPropertyPlaybackDuration] = item.asset.duration.seconds
                    info[MPNowPlayingInfoCollectionIdentifier] = reference.damId
                    info[MPNowPlayingInfoPropertyChapterNumber] = reference.chapterNum - 1
                    //self.info[MPNowPlayingInfoPropertyCurrentLanguageOptions] postpone
                    info[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1.0
                    info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = item.currentTime().seconds
                    info[MPNowPlayingInfoPropertyExternalContentIdentifier] = reference.getS3Key()
                    info[MPNowPlayingInfoPropertyExternalUserProfileIdentifier] =
                        "Hear Holy Bible XXX" // necessary?
                    info[MPNowPlayingInfoPropertyIsLiveStream] = 0.0 // or 0.0 for false
   
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
        let title = self.currentBookChapter + ":" + String(verse)
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()
        info[MPMediaItemPropertyTitle] = title
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = position
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        
        self.updateTextPosition(nodeId: reference.getNodeId(verse: verse))
    }
    
    func updateNowPlaying(position: Double) {
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
