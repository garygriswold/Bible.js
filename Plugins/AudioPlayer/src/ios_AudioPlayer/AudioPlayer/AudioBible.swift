//
//  BibleReader.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 7/31/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import AVFoundation
import AWS

public class AudioBible : NSObject {
    
    private let controller: AudioBibleController
    private let tocAudioBible: TOCAudioBible
    private let controlCenter: AudioControlCenter
    private let audioAnalytics: AudioAnalytics
    private var player: AVPlayer?
    // Transient Variables
    private var currReference: Reference
    private var nextReference: Reference?
    
    init(controller: AudioBibleController, tocBible: TOCAudioBible, reference: Reference) {
        self.controller = controller
        self.tocAudioBible = tocBible
        self.currReference = reference
        self.controlCenter = AudioControlCenter.shared
        self.audioAnalytics = AudioAnalytics(mediaSource: "FCBH",
                                             mediaId: self.currReference.damId,
                                             languageId: tocBible.dbpLanguageCode,
                                             silLang: "User's text lang setting")
        
        print("INSIDE BibleReader \(self.currReference.damId)")
        MediaPlayState.retrieve(mediaId: self.currReference.damId)
    }
    
    deinit {
        print("***** Deinit AudioBible *****")
    }
    
    func getPlayer() -> AVPlayer? {
        return self.player
    }
    
    func getCurrentReference() -> Reference {
        return self.currReference
    }
    
    func isPlaying() -> Bool {
        return (self.player != nil) ? self.player!.rate > 0.0 : false
    }
    
    public func beginReadFile() {
        print("BibleReader.BEGIN Read File")
        AwsS3Cache.shared.readFile(s3Bucket: self.currReference.getS3Bucket(),
                   s3Key: self.currReference.getS3Key(),
                   expireInterval: Double.infinity,
                   getComplete: {
                    url in
                    if let audioURL = url {
                        self.initAudio(url: audioURL)
                    }
        })
    }
    
    func initAudio(url: URL) {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        print("Player Item Status \(playerItem.status)")
        
        let seekTime = backupSeek(state: MediaPlayState.currentState)
        if (CMTimeGetSeconds(seekTime) > 0.1) {
            playerItem.seek(to: seekTime)
        }
        self.player = AVPlayer(playerItem: playerItem)
        self.player?.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        self.initNotifications()
        
        self.play()
        self.preFetchNextChapter(reference: self.currReference)
        
        self.controller.playHasStarted()
        
        self.controlCenter.setupControlCenter(player: self)
        self.controlCenter.nowPlaying(player: self)
    }
    
    func backupSeek(state: MediaPlayState) -> CMTime {
        if (state.mediaUrl == self.currReference.toString()) {
            return state.position
        } else {
            return kCMTimeZero
        }
    }
    
    func play() {
        if let play = self.player {
            print("\n*********** PLAY *************")
            play.play()
            self.audioAnalytics.playStarted(item: self.currReference.toString(), position: play.currentTime())
        }
    }
    
    func pause() {
        if let play = self.player {
            print("\n*********** PAUSE *************")
            play.pause()
            self.audioAnalytics.playEnded(item: self.currReference.toString(), position: play.currentTime())
            self.updateMediaPlayStateTime()
        }
    }
    
    func stop() {
        if self.player != nil && self.player!.rate > 0.0 {
            self.pause()
        }
        self.removeNotifications()
        if self.player != nil {
            self.player = nil
        }
        self.controller.playHasStopped()
    }
    
    /** This method is called by AudioControlCenter.swift when user clicks the next button. */
    func nextChapter() {
        if let curr = self.nextReference {
            self.currReference = curr
            self.addNextChapter(reference: curr)
            self.preFetchNextChapter(reference: curr)
        } else {
            self.stop()
            MediaPlayState.clear() // Must do after stop, because stop updates
        }
    }
    
    /** This method is called by AudioControlCenter.swift when user clicks the prior button. */
    func priorChapter() {
        if let item = self.player?.currentItem {
            if item.currentTime().seconds < 1.0 {
                if let prior = self.tocAudioBible.priorChapter(reference: self.currReference) {
                    self.nextReference = self.currReference
                    self.currReference = prior
                    self.addNextChapter(reference: self.currReference)
                }
            } else {
                item.seek(to: kCMTimeZero)
                self.controlCenter.nowPlaying(player: self)
            }
        }
        self.player?.currentItem?.seek(to: kCMTimeZero)
    }
    
    func initNotifications() {
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
                           name: .UIApplicationDidFinishLaunching,
                           object: nil)
        notify.addObserver(self,
                           selector: #selector(applicationWillEnterForeground(note:)),
                           name: .UIApplicationWillEnterForeground,
                           object: nil)
        notify.addObserver(self,
                           selector: #selector(applicationDidEnterBackground(note:)),
                           name: .UIApplicationDidEnterBackground,
                           object: nil)
        notify.addObserver(self,
                           selector: #selector(applicationWillTerminate(note:)),
                           name: .UIApplicationWillTerminate,
                           object: nil)
    }

    func removeNotifications() {
        print("\n ***** INSIDE REMOVE NOTIFICATIONS")
        let notify = NotificationCenter.default
        notify.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        notify.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
        notify.removeObserver(self, name: .AVPlayerItemPlaybackStalled, object: nil)
        notify.removeObserver(self, name: .AVPlayerItemNewErrorLogEntry, object: nil)
        //notify.removeObserver(self, name: .AVPlayerItemNewAccessLogEntry, object: nil)
        //notify.removeObserver(self, name: .AVPlayerItemTimeJumped, object: nil)
 
        notify.removeObserver(self, name: .UIApplicationDidFinishLaunching, object: nil)
        notify.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
        notify.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
        notify.removeObserver(self, name: .UIApplicationWillTerminate, object: nil)
    }
    
    @objc func playerItemDidPlayToEndTime(note:Notification) {
        print("\n** DID PLAY TO END \(String(describing: note.object))")
        self.nextChapter()
    }
    @objc func playerItemFailedToPlayToEndTime(note:Notification) {
        print("\n********* FAILED TO PLAY TO END *********\(String(describing: note.object))")
    }
    @objc func playerItemPlaybackStalled(note:Notification) {
        print("\n****** PLAYBACK STALLED \(String(describing: note.object))")
    }
    @objc func playerItemNewErrorLogEntry(note:Notification) {
        print("\n****** ERROR LOG ENTRY \(String(describing: note.object))\n\(String(describing: self.player?.currentItem?.errorLog()))")
    }
    @objc func playerItemNewAccessLogEntry(note:Notification) {
        print("\n****** ACCESS LOG ENTRY \(String(describing: note.object))\n\(String(describing: self.player?.currentItem?.accessLog()))")
    }
    @objc func playerItemTimeJumped(note:Notification) {
        print("\n****** TIME JUMPED \(String(describing: note.object))")
    }
    
    /**
    * This method is called when an App is first, launched, not when it is restarted in foreground
    */
    @objc func applicationDidFinishLaunching(note:Notification) {
        print("\n****** APP DID FINISH LAUNCHING \(String(describing: note.object)) \(Date().timeIntervalSince1970)")
    }
    /**
    * This method is called when an already running App, which went to background, restarts in foreground.
    */
    @objc func applicationWillEnterForeground(note:Notification) {
        print("\n****** APP WILL ENTER FOREGROUND \(String(describing: note.object)) \(Date().timeIntervalSince1970)")
    }
    /**
    * This method is called when the Home button or Lock button terminate the foreground App
    */
    @objc func applicationDidEnterBackground(note:Notification) {
        print("\n****** APP DID ENTER BACKGROUND \(String(describing: note.object)) \(Date().timeIntervalSince1970)")
    }
    /**
    * This method is called when the App is fully killed.  It is not affected by the Home or Lock button
    */
    @objc func applicationWillTerminate(note:Notification) {
        print("\n****** APP WILL TERMINATE \(String(describing: note.object)) \(Date().timeIntervalSince1970)")
    }
    
    private func updateMediaPlayStateTime() {
        var result: CMTime = kCMTimeZero
        if let audioChapter = self.currReference.audioChapter {
            if let currentTime = self.player?.currentTime() {
                let verse: Int = audioChapter.findVerseByPosition(priorVerse: 1, time: currentTime)
                result = audioChapter.findPositionOfVerse(verse: verse)
            }
        }
        MediaPlayState.update(url: self.currReference.toString(), time: result)
    }
    
    private func addNextChapter(reference: Reference) {
        self.pause()
        AwsS3Cache.shared.readFile(s3Bucket: reference.getS3Bucket(),
                                   s3Key: reference.getS3Key(),
                                   expireInterval: Double.infinity,
                                   getComplete: {
                                    url in
                                    if let audioURL = url {
                                        let asset = AVAsset(url: audioURL)
                                        let playerItem = AVPlayerItem(asset: asset)
                                        self.player?.replaceCurrentItem(with: playerItem)
                                        self.controlCenter.nowPlaying(player: self)
                                        self.play()
                                    }
        })
    }
    
    private func preFetchNextChapter(reference: Reference) {
        self.readVerseMetaData(reference: reference)
        self.nextReference = self.tocAudioBible.nextChapter(reference: reference)
        if let next = self.nextReference {
            AwsS3Cache.shared.readFile(s3Bucket: next.getS3Bucket(),
                                       s3Key: next.getS3Key(),
                                       expireInterval: Double.infinity,
                                       getComplete: { url in })
        }
    }
    
    private func readVerseMetaData(reference: Reference) {
        let reader = MetaDataReader()
        reader.readVerseAudio(damid: reference.damId, sequence: reference.sequence, bookId: reference.book, chapter: reference.chapter, complete: {
            audioChapter in
            if (audioChapter != nil) {
                reference.audioChapter = audioChapter
                //print("PARSED DATA \(self.audioChapter?.toString())")
            }
        })
    }
}

