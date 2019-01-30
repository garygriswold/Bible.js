//
//  AudioBible.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 7/31/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import AVFoundation
import AWS
import Utility

class AudioBible {
    
    private static var instance: AudioBible?
    static func shared(controller: AudioBibleController) -> AudioBible {
        if (AudioBible.instance == nil) {
            AudioBible.instance = AudioBible(controller: controller)
        }
        return AudioBible.instance!
    }
    
    private let controller: AudioBibleController
    private let mediaPlayState: MediaPlayState
    private let controlCenter: AudioControlCenter
    private var audioAnalytics: AudioFauxAnalytics?
    private var player: AVPlayer?
    // Transient Variables
    private var currReference: AudioReference?
    private var nextReference: AudioReference?
    
    private init(controller: AudioBibleController) {
        self.controller = controller
        self.mediaPlayState = MediaPlayState.audio
        self.controlCenter = AudioControlCenter.shared
        self.controlCenter.setupControlCenter(player: self)
        self.initNotifications()
        print("***** Init AudioBible *****")
    }
    
    deinit {
        print("***** Deinit AudioBible *****")
    }
    
    func getPlayer() -> AVPlayer? {
        return self.player
    }
    
    func getCurrentReference() -> AudioReference? {
        return self.currReference
    }
    
    func isPlaying() -> Bool {
        return (self.player != nil) ? self.player!.rate > 0.0 : false
    }
    
    func beginReadFile(reference: AudioReference) {
        print("BibleReader.BEGIN Read File")
        self.currReference = reference
        self.audioAnalytics = AudioFauxAnalytics(mediaSource: reference.tocAudioBook.testament.bible.mediaSource,
                                             mediaId: reference.damId,
                                             languageId: reference.iso3,
                                             textVersion: reference.bibleId,
                                             silLang: reference.iso3)
        self.readVerseMetaData(reference: reference)
        print("INSIDE BibleReader \(reference.damId)")
        self.mediaPlayState.retrieve(mediaId: reference.damId)
        AwsS3Cache.shared.readFile(s3Bucket: reference.getS3Bucket(),
                   s3Key: reference.getS3Key(),
                   expireInterval: Double.infinity,
                   getComplete: { [unowned self] url in
                    if let audioURL = url {
                        self.initAudio(url: audioURL, reference: reference)
                    }
        })
    }
    
    private func initAudio(url: URL, reference: AudioReference) {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        print("Player Item Status \(playerItem.status)")
        
        let seekTime = backupSeek(state: mediaPlayState, reference: reference)
        if (CMTimeGetSeconds(seekTime) > 0.1) {
            playerItem.seek(to: seekTime, completionHandler: nil) // nil handler added 6/2/18
        }
        self.player = AVPlayer(playerItem: playerItem)
        self.player?.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        
        self.controller.audioReadyToPlay(enabled: true)
        self.preFetchNextChapter(reference: reference)
    }
    
    private func backupSeek(state: MediaPlayState, reference: AudioReference) -> CMTime {
        if (state.mediaUrl == reference.toString()) {
            if reference.audioChapter != nil {
                return state.position
            } else {
                let duration: Int64 = Int64(Date().timeIntervalSince(state.timestamp))
                let backupSec: Int = String(duration).count // could multiply by a factor here
                let backupTime: CMTime = CMTimeMake(value: Int64(backupSec), timescale: 1)
                return(CMTimeSubtract(state.position, backupTime))
            }
        } else {
            return CMTime.zero
        }
    }
    
    func play() {
        if let play = self.player {
            if let reference = self.currReference {
                print("\n*********** PLAY *************")
                play.play()
                self.audioAnalytics?.playStarted(item: reference.toString(), position: play.currentTime())
                self.controlCenter.nowPlaying(player: self)
            }
        }
    }
    
    func pause() {
        if let play = self.player {
            if let reference = self.currReference {
                print("\n*********** PAUSE *************")
                play.pause()
                self.audioAnalytics?.playEnded(item: reference.toString(), position: play.currentTime())
                self.updateMediaPlayStateTime(reference: reference)
            }
        }
    }
    
    func stop() {
        if self.player != nil && self.player!.rate > 0.0 {
            self.pause()
        }
    }
    
    /** This method is called when the prior chapter completes, and by AudioControlCenter.swift
     * when the user clicks the next button.
     */
    func nextChapter() {
        if let play = self.player {
            let startPlayRate = play.rate
            if let curr = self.nextReference {
                self.currReference = curr
                self.addNextChapter(reference: curr)
                NotificationCenter.default.post(name: AudioBibleController.AUDIO_CHAP_CHANGED, object: 1)
                if startPlayRate == 0 {
                    self.audioAnalytics?.playStarted(item: curr.toString(), position: play.currentTime())
                }
            } else {
                self.stop()
                self.mediaPlayState.delete() // Must do after stop, because stop updates
            }
        }
    }
    
    /** This method is called by AudioControlCenter.swift when user clicks the prior button. */
    func priorChapter() {
        if let play = self.player {
            let startPlayRate = play.rate
            if let item = play.currentItem {
                if item.currentTime().seconds < 1.0 {
                    if let prior = self.currReference?.priorChapter() {
                        self.nextReference = self.currReference
                        self.currReference = prior
                        self.addNextChapter(reference: prior)
                        NotificationCenter.default.post(name: AudioBibleController.AUDIO_CHAP_CHANGED,
                                                        object: -1)
                        if startPlayRate == 0 {
                            self.audioAnalytics?.playStarted(item: prior.toString(), position: play.currentTime())
                        }
                    }
                } else {
                    item.seek(to: CMTime.zero, completionHandler: nil) // nil handler added 7/2/18
                    self.controlCenter.nowPlaying(player: self)
                    if startPlayRate == 0 {
                        if let curr = self.currReference {
                            self.audioAnalytics?.playStarted(item: curr.toString(), position: CMTime.zero)
                        }
                    }
                }
            }
            //play.currentItem?.seek(to: kCMTimeZero)
        }
    }
    
    private func initNotifications() {
        let notify = NotificationCenter.default
        notify.addObserver(self,
                           selector: #selector(playerItemDidPlayToEndTime(note:)),
                           name: .AVPlayerItemDidPlayToEndTime,
                           object: nil)
        notify.addObserver(self,
                           selector: #selector(playerItemFailedToPlayToEndTime(note:)),
                           name: .AVPlayerItemFailedToPlayToEndTime,
                           object: nil)
        notify.addObserver(self,
                           selector: #selector(playerItemPlaybackStalled(note:)),
                           name: .AVPlayerItemPlaybackStalled,
                           object: nil)
        notify.addObserver(self,
                           selector: #selector(playerItemNewErrorLogEntry(note:)),
                           name: .AVPlayerItemNewErrorLogEntry,
                           object: nil)
        /*notify.addObserver(self,
                            selector: #selector(playerItemNewAccessLogEntry(note:)),
                            name: .AVPlayerItemNewAccessLogEntry,
                            object: nil)*/
        /*notify.addObserver(self,
                            selector: #selector(playerItemTimeJumped(note:)),
                            name: .AVPlayerItemTimeJumped,
                            object: nil)*/
        notify.addObserver(self,
                           selector: #selector(applicationDidFinishLaunching(note:)),
                           name: UIApplication.didFinishLaunchingNotification,
                           object: nil)
        notify.addObserver(self,
                           selector: #selector(applicationWillEnterForeground(note:)),
                           name: UIApplication.willEnterForegroundNotification,
                           object: nil)
        notify.addObserver(self,
                           selector: #selector(applicationDidEnterBackground(note:)),
                           name: UIApplication.didEnterBackgroundNotification,
                           object: nil)
        notify.addObserver(self,
                           selector: #selector(applicationWillTerminate(note:)),
                           name: UIApplication.willTerminateNotification,
                           object: nil)
    }

    @objc private func playerItemDidPlayToEndTime(note:Notification) {
        print("\n** DID PLAY TO END \(String(describing: note.object))")
        self.nextChapter()
    }
    @objc private func playerItemFailedToPlayToEndTime(note:Notification) {
        print("\n********* FAILED TO PLAY TO END *********\(String(describing: note.object))")
    }
    @objc private func playerItemPlaybackStalled(note:Notification) {
        print("\n****** PLAYBACK STALLED \(String(describing: note.object))")
    }
    @objc private func playerItemNewErrorLogEntry(note:Notification) {
        print("\n****** ERROR LOG ENTRY \(String(describing: note.object))\n\(String(describing: self.player?.currentItem?.errorLog()))")
    }
    @objc private func playerItemNewAccessLogEntry(note:Notification) {
        print("\n****** ACCESS LOG ENTRY \(String(describing: note.object))\n\(String(describing: self.player?.currentItem?.accessLog()))")
    }
    @objc private func playerItemTimeJumped(note:Notification) {
        print("\n****** TIME JUMPED \(String(describing: note.object))")
    }
    
    /**
    * This method is called when an App is first, launched, not when it is restarted in foreground
    */
    @objc private func applicationDidFinishLaunching(note:Notification) {
        print("\n****** APP DID FINISH LAUNCHING \(String(describing: note.object)) \(Date().timeIntervalSince1970)")
    }
    /**
    * This method is called when an already running App, which went to background, restarts in foreground.
    */
    @objc private func applicationWillEnterForeground(note:Notification) {
        print("\n****** APP WILL ENTER FOREGROUND \(String(describing: note.object)) \(Date().timeIntervalSince1970)")
    }
    /**
    * This method is called when the Home button or Lock button terminate the foreground App
    */
    @objc private func applicationDidEnterBackground(note:Notification) {
        print("\n****** APP DID ENTER BACKGROUND \(String(describing: note.object)) \(Date().timeIntervalSince1970)")
    }
    /**
    * This method is called when the App is fully killed.  It is not affected by the Home or Lock button
    */
    @objc private func applicationWillTerminate(note:Notification) {
        print("\n****** APP WILL TERMINATE \(String(describing: note.object)) \(Date().timeIntervalSince1970)")
        self.stop()
    }
    
    private func updateMediaPlayStateTime(reference: AudioReference) {
        var result: CMTime = CMTime.zero
        if let currentTime = self.player?.currentTime() {
            if let audioChapter = reference.audioChapter {
                let verse: Int = audioChapter.findVerseByPosition(priorVerse: 1, time: currentTime)
                result = audioChapter.findPositionOfVerse(verse: verse)
            } else {
                result = currentTime
            }
        }
        self.mediaPlayState.update(mediaUrl: reference.toString(), position: result)
    }
    
    private func addNextChapter(reference: AudioReference) {
        self.player?.pause()
        AwsS3Cache.shared.readFile(s3Bucket: reference.getS3Bucket(),
                                   s3Key: reference.getS3Key(),
                                   expireInterval: Double.infinity,
                                   getComplete: { [unowned self] url in
                                    if let audioURL = url {
                                        let asset = AVAsset(url: audioURL)
                                        let playerItem = AVPlayerItem(asset: asset)
                                        self.player?.replaceCurrentItem(with: playerItem)
                                        self.player?.play()
                                        self.readVerseMetaData(reference: reference)
                                        self.controlCenter.nowPlaying(player: self)
                                    }
                                    self.preFetchNextChapter(reference: reference)
        })
    }
    
    private func preFetchNextChapter(reference: AudioReference) {
        self.nextReference = reference.nextChapter()
        if let next = self.nextReference {
            print("Prefetch \(next.toString())")
            AwsS3Cache.shared.readFile(s3Bucket: next.getS3Bucket(),
                                       s3Key: next.getS3Key(),
                                       expireInterval: Double.infinity,
                                       getComplete: { url in })
        }
    }
    
    private func readVerseMetaData(reference: AudioReference) {
        reference.audioChapter = self.controller.audioTOCBible?.readVerseAudio(
            damid: reference.damId, bookId: reference.bookId, chapter: reference.chapterNum)
    }
}

