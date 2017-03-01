/**
 *  VideoPlayer.swift
 *  VideoPlayer
 *
 *  Created by Gary Griswold on 1/16/17.
 *  Copyright © 2017 ShortSands. All rights reserved.
 *  Created by garygriswold on 1/26/17.
 *  This is based up the following plugin:
 *  https://github.com/nchutchind/cordova-plugin-streaming-media
 */
import AVFoundation
import AVKit

class VideoViewPlayer : NSObject {
    let controller: AVPlayerViewController
    var timeObserverToken: Any?
    
    init(videoId: String, videoUrl: String) {
	    print("INSIDE VideoViewPlayer ")
        let url = URL(string: videoUrl)!
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        let seekTime: Int64 = 0 // should be recovered
        if (seekTime > 0) {
            let time = CMTime(value: seekTime, timescale: 1)
            playerItem.seek(to: time)
        }
        let player = AVPlayer(playerItem: playerItem)
        self.controller = AVPlayerViewController()
        self.controller.showsPlaybackControls = true
        self.controller.initNotifications()
        self.controller.player = player
        print("CONSTRUCTED")
    }
    deinit {
        // If a time observer exists, remove it
        if let token = self.timeObserverToken {
            self.controller.player?.removeTimeObserver(token)
            self.timeObserverToken = nil
        }
        self.controller.removeNotifications()
    }
    func begin() {
        print("VideoViewPlayer.BEGIN")
        addPeriodicTimeObserver()
        self.controller.player?.play()
        
        //dumpAssetProperties(asset: (self.controller.player?.currentItem?.asset)!)
        //dumpPlayerItemProperties(playerItem: (self.controller.player?.currentItem)!)
        //dumpPlayerProperties(player: (self.controller.player)!)
        //dumpControllerProperties(controller: self.controller)
        //dumpUIControllerProperties(controller: self.controller)
    }
    func addPeriodicTimeObserver() {
        let interval = CMTime(seconds: 5.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        // Queue on which to invoke the callback
        let mainQueue = DispatchQueue.main
        // Add time observer
        self.timeObserverToken =
            self.controller.player?.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) {
                //[weak self] time in // needed if I reference self
                time in
                //print("TIME OBSERVER \(time)")
                //print("TIME VALUE \(time.value) \(time.timescale)  \(Double(time.value)/Double(time.timescale))")
                print("TIME VALUE \(time.value) \(time.timescale)  \(time.value / Int64(time.timescale))")
                // dispatch event to JS somehow
        }
    }
    func dumpAssetProperties(asset: AVAsset) {
        print("duration=\(asset.duration)")
        print("preciseTiming=\(asset.providesPreciseDurationAndTiming)")
        print("create date=\(asset.creationDate)")
        print("preferredRate=\(asset.preferredRate)")
        print("preferredTrans=\(asset.preferredTransform)")
        print("preferredVolume=\(asset.preferredVolume)")
        print("isPlayable=\(asset.isPlayable)")
        print("isExportable=\(asset.isExportable)")
        print("isReadable=\(asset.isReadable)")
        print("isComposable=\(asset.isComposable)")
        print("hasProtectedContent=\(asset.hasProtectedContent)")
        for track in asset.tracks {
            print("track=\(track)")
        }
        print("metaData=\(asset.metadata)")
        print("availableMediaChar=\(asset.availableMediaCharacteristicsWithMediaSelectionOptions)")
        print("referenceRestrictions=\(asset.referenceRestrictions)")
    }
    func dumpPlayerItemProperties(playerItem: AVPlayerItem) {
        switch playerItem.status {
        case .unknown:
            print("playerItemStatus=.unknown")
        case .readyToPlay:
            print("playerItemStatus=.readyToPlay")
        case .failed:
            print("playerItemStatus=.failed")
        }
        print("duration=\(playerItem.duration)")
        print("timebase=\(playerItem.timebase)")
        print("presentationSize=\(playerItem.presentationSize)")
        print("error=\(playerItem.error)")
        print("isPlaybackLikelyToKeepUp=\(playerItem.isPlaybackLikelyToKeepUp)")
        print("isPlaybackBufferEmpty=\(playerItem.isPlaybackBufferEmpty)")
        print("isPlaybackBufferFull=\(playerItem.isPlaybackBufferFull)")
        print("canPlayReverse=\(playerItem.canPlayReverse)")
        print("canPlayFastForward=\(playerItem.canPlayFastForward)")
        print("canPlayFastReverse=\(playerItem.canPlayFastReverse)")
        print("canPlaySlowForward=\(playerItem.canPlaySlowForward)")
        print("canPlaySlowReverse=\(playerItem.canPlaySlowReverse)")
        print("canStepBackward=\(playerItem.canStepBackward)")
        print("canStepForward=\(playerItem.canStepForward)")
        print("currentTime=\(playerItem.currentTime())")
        print("currentDate=\(playerItem.currentDate())")
        print("forwardPlaybackEndTime=\(playerItem.forwardPlaybackEndTime)")
        print("reversePlaybackEndTime=\(playerItem.reversePlaybackEndTime)")
        print("preferredPeakBitRate=\(playerItem.preferredPeakBitRate)")
        print("videoComposition=\(playerItem.videoComposition)")
        print("accessLog=\(playerItem.accessLog())")
        print("errorLog=\(playerItem.errorLog())")
    }
    func dumpPlayerProperties(player: AVPlayer) {
        print("rate=\(player.rate)")
        switch player.actionAtItemEnd {
        case .advance:
            print("actionAtItemEnd=.advance")
        case .pause:
            print("actionAtItemEnd=.pause")
        case .none:
            print("actionAtItemEnd=.none")
        }
        print("currentTime=\(player.currentTime())")
        print("isClosedCaptionDisplayEnabled=\(player.isClosedCaptionDisplayEnabled)")
        print("allowsExternalPlayback=\(player.allowsExternalPlayback)")
        print("isExternalPlaybackActive=\(player.isExternalPlaybackActive)")
        print("usesExternalPlaybackWhileExternalScreenIsActive=\(player.usesExternalPlaybackWhileExternalScreenIsActive)")
        print("externalPlaybackVideoGravity=\(player.externalPlaybackVideoGravity)")
        print("isMuted=\(player.isMuted)")
        print("volume=\(player.volume)")
        switch player.status {
        case .unknown:
            print("playerStatus=.unknown")
        case .readyToPlay:
            print("playerStatus=.readyToPlay")
        case .failed:
            print("playerStatus=.failed")
        }
        print("error=\(player.error)")
        print("currentItem=\(player.currentItem)")
    }
    func dumpControllerProperties(controller: AVPlayerViewController) {
        print("showsPlaybackControls=\(controller.showsPlaybackControls)")
        print("contentOverlayView=\(controller.contentOverlayView)")
        print("isReadyForDisplay=\(controller.isReadyForDisplay)")
        print("videoBounds=\(controller.videoBounds)")
        print("videoGravity=\(controller.videoGravity)")
    }
    func dumpUIControllerProperties(controller: AVPlayerViewController) {
        print("prefersStatusBarHidden=\(controller.prefersStatusBarHidden)")
        print("modalPresentationCapturesStatusBarAppearance=\(controller.modalPresentationCapturesStatusBarAppearance)")
        print("toolBarItems=\(controller.toolbarItems)")
        print("modalPresentationStyle=\(controller.modalPresentationStyle.rawValue)")
    }
}

