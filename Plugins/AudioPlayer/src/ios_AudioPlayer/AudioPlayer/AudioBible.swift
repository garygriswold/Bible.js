//
//  BibleReader.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 7/31/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import Foundation
import AVFoundation
import AWS

public class AudioBible : NSObject {
    
    private let controller: AudioBibleController
    private let tocAudioBible: TOCAudioBible
    private let audioAnalytics: AudioAnalytics
    private var player: AVPlayer?
    // Transient Variables
    private var currReference: Reference
    private var nextReference: Reference?
    
    init(controller: AudioBibleController, tocBible: TOCAudioBible, reference: Reference) {
        self.controller = controller
        self.tocAudioBible = tocBible
        self.currReference = reference
        self.audioAnalytics = AudioAnalytics(mediaSource: "FCBH",
                                             mediaId: self.currReference.damId,
                                             languageId: tocBible.languageCode,
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
        
        self.audioAnalytics.playStarted(item: self.currReference.toString(), position: seekTime)
    }
    
    func backupSeek(state: MediaPlayState) -> CMTime {
        if (state.mediaUrl == self.currReference.toString()) {
            return state.position
        } else {
            return kCMTimeZero
        }
    }
    
    func play() {
        self.player?.play()
        print("Player Status = \(String(describing: self.player?.status))")
    }
    
    func pause() {
        self.player?.pause()
        print("Pause Status = \(String(describing: self.player?.status))")
    }
    
    func stop() {
        self.removeNotifications()
        if self.player != nil {
            self.player = nil
        }
        self.controller.playHasStopped()
    }
    
    func initNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidPlayToEndTime(note:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemFailedToPlayToEndTime(note:)),
                                               name: .AVPlayerItemFailedToPlayToEndTime,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemPlaybackStalled(note:)),
                                               name: .AVPlayerItemPlaybackStalled,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemNewErrorLogEntry(note:)),
                                               name: .AVPlayerItemNewErrorLogEntry,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillResignActive(note:)),
                                               name: .UIApplicationWillResignActive,
                                               object: nil)
        /*NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemNewAccessLogEntry(note:)),
                                               name: .AVPlayerItemNewAccessLogEntry,
                                               object: nil)*/
        /*NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemTimeJumped(note:)),
                                               name: .AVPlayerItemTimeJumped,
                                               object: nil)*/
    }

    func removeNotifications() {
        print("\n ***** INSIDE REMOVE NOTIFICATIONS")
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemPlaybackStalled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemNewErrorLogEntry, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive, object: nil)
        //NotificationCenter.default.removeObserver(self, name: .AVPlayerItemNewAccessLogEntry, object: nil)
        //NotificationCenter.default.removeObserver(self, name: .AVPlayerItemTimeJumped, object: nil)
    }
    
    @objc func playerItemDidPlayToEndTime(note:Notification) {
        print("\n** DID PLAY TO END \(String(describing: note.object))")
        self.advanceToNextItem()
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
     * This method is called when the Home button is clicked or double clicked.
     * And when an interruption occurs, such as a phone call.
     */
    @objc func applicationWillResignActive(note:Notification) {
        print("\n******* APPLICATION WILL RESIGN ACTIVE *** in AVPlayerViewController")
        self.sendAudioAnalytics()
        self.updateMediaPlayStateTime()
    }
    
    func updateMediaPlayStateTime() {
        var result: CMTime = kCMTimeZero
        if let audioChapter = self.currReference.audioChapter {
            if let currentTime = self.player?.currentTime() {
                let verse: Int = audioChapter.findVerseByPosition(priorVerse: 1, time: currentTime)
                result = audioChapter.findPositionOfVerse(verse: verse)
            }
        }
        MediaPlayState.update(url: self.currReference.toString(), time: result)
    }
    
    func advanceToNextItem() {
        if let curr = self.nextReference {
            self.currReference = curr
            self.addNextChapter(reference: curr)
            self.preFetchNextChapter(reference: curr)
        } else {
            self.sendAudioAnalytics()
            MediaPlayState.clear()
            self.stop()
        }
    }
    
    private func addNextChapter(reference: Reference) {
        AwsS3Cache.shared.readFile(s3Bucket: reference.getS3Bucket(),
                                   s3Key: reference.getS3Key(),
                                   expireInterval: Double.infinity,
                                   getComplete: {
                                    url in
                                    if let audioURL = url {
                                        let asset = AVAsset(url: audioURL)
                                        let playerItem = AVPlayerItem(asset: asset)
                                        self.player?.replaceCurrentItem(with: playerItem)
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
        reader.readVerseAudio(damid: reference.damId, sequence: reference.sequence, bookId: reference.book, chapter: reference.chapter, readComplete: {
            audioChapter in
            reference.audioChapter = audioChapter
            //print("PARSED DATA \(self.audioChapter?.toString())")
        })
    }
    
    func sendAudioAnalytics() {
        print("\n*********** INSIDE SAVE ANALYTICS *************")
        let currTime = (self.player != nil) ? self.player!.currentTime() : kCMTimeZero
        self.audioAnalytics.playEnded(item: self.currReference.toString(), position: currTime)
    }
}

