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
    
    let controller: AudioBibleViewController
    let tocAudioBible: TOCAudioBible
    let s3Bucket: String
    let version: String
    let fileType: String
    var audioChapter: TOCAudioChapter?
    var player: AVQueuePlayer?
    // Transient Variables
    var currReference: Reference
    var nextReference: Reference?
    
    init(controller: AudioBibleViewController, tocBible: TOCAudioBible,
         version: String, reference: Reference, fileType: String) {
        self.controller = controller
        self.tocAudioBible = tocBible
        self.s3Bucket = "audio-us-west-2-shortsands"
        self.version = version
        self.fileType = fileType
        self.currReference = reference
        
        print("INSIDE BibleReader \(self.version)")
        MediaPlayState.retrieve(mediaId: self.version)
    }
    
    deinit {
        print("***** Deinit AudioBible *****")
    }
    
    public func beginStreaming() {
        let s3Key = self.currReference.getS3Key(damId: self.version, fileType: self.fileType)
        AwsS3.shared.preSignedUrlGET(
            s3Bucket: self.s3Bucket,
            s3Key: s3Key,
            expires: 3600,
            complete: { url in
                print("computed GET URL \(String(describing: url))")
                if let audioUrl = url {
                    self.initAudio(url: audioUrl)
                }
            }
        )
    }
    
    public func beginDownload() {
        print("BibleReader.BEGIN Download")
        var filePath: URL = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
        filePath = filePath.appendingPathComponent("Library")
        filePath = filePath.appendingPathComponent("Caches")
        let s3Key = self.currReference.getS3Key(damId: self.version, fileType: self.fileType)
        filePath = filePath.appendingPathComponent(s3Key)
        print("FilePath \(filePath.absoluteString)")
        
        AwsS3.shared.downloadFile(
            s3Bucket: self.s3Bucket,
            s3Key: s3Key,
            filePath: filePath,
            complete: { err in
                print("I RECEIVED DownloadFile CALLBACK \(String(describing: err))")
                if (err == nil) {
                    self.initAudio(url: filePath)
                }
            }
        )
    }
    
    public func beginLocal() {
        print("BibleReader.BEGIN Download")
        var filePath: URL = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
        filePath = filePath.appendingPathComponent("Library")
        filePath = filePath.appendingPathComponent("Caches")
        let s3Key = self.currReference.getS3Key(damId: self.version, fileType: self.fileType)
        filePath = filePath.appendingPathComponent(s3Key)
        print("FilePath \(filePath.absoluteString)")
        self.initAudio(url: filePath)
     }
    
    func initAudio(url: URL) {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        print("Player Item Status \(playerItem.status)")
        
        let seekTime = backupSeek(state: MediaPlayState.currentState)
        if (CMTimeGetSeconds(seekTime) > 0.1) {
            playerItem.seek(to: seekTime)
        }
        self.player = AVQueuePlayer(items: [playerItem])
        self.player?.actionAtItemEnd = AVPlayerActionAtItemEnd.advance
        self.initNotifications()
        
        //delegate.completionHandler = complete
        //delegate.videoAnalytics = self.videoAnalytics
        //self.controller.delegate = delegate
        
        self.play()
        self.nextReference = self.prepareQueue(reference: self.currReference)
        
        self.controller.playHasStarted()
    }
    
    func backupSeek(state: MediaPlayState) -> CMTime {
        if (state.mediaUrl == self.currReference.toString()) {
            return state.position
        } else {
            MediaPlayState.update(url: self.currReference.toString())
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
            self.updateMediaPlayStateTime()
            self.player!.removeAllItems()
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
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemNewAccessLogEntry, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemTimeJumped, object: nil)
    }
    
    func playerItemDidPlayToEndTime(note:Notification) {
        print("\n** DID PLAY TO END \(String(describing: note.object))")
        //sendVideoAnalytics(isStart: false, isDone: true)
        
        if let curr = self.nextReference {
            self.currReference = curr
            self.nextReference = self.prepareQueue(reference: curr)
        } else {
            MediaPlayState.clear()
            self.stop()
        }
    }
    func playerItemFailedToPlayToEndTime(note:Notification) {
        print("\n********* FAILED TO PLAY TO END *********\(String(describing: note.object))")
    }
    func playerItemPlaybackStalled(note:Notification) {
        print("\n****** PLAYBACK STALLED \(String(describing: note.object))")
    }
    func playerItemNewErrorLogEntry(note:Notification) {
        print("\n****** ERROR LOG ENTRY \(String(describing: note.object))\n\(String(describing: self.player?.currentItem?.errorLog()))")
    }
    func playerItemNewAccessLogEntry(note:Notification) {
        print("\n****** ACCESS LOG ENTRY \(String(describing: note.object))\n\(String(describing: self.player?.currentItem?.accessLog()))")
    }
    func playerItemTimeJumped(note:Notification) {
        print("\n****** TIME JUMPED \(String(describing: note.object))")
    }
    /**
     * This method is called when the Home button is clicked or double clicked.
     * MediaPlayState is saved in this method
     */
    func applicationWillResignActive(note:Notification) {
        print("\n******* APPLICATION WILL RESIGN ACTIVE *** in AVPlayerViewController")
        //sendVideoAnalytics(isStart: false, isDone: false)
        self.updateMediaPlayStateTime()
    }
    
    private func updateMediaPlayStateTime() {
        var result: CMTime = kCMTimeZero
        if let currentTime = self.player?.currentTime() {
            if let time: CMTime = self.audioChapter?.findVerseByPosition(time: currentTime) {
                result = time
            }
        }
        MediaPlayState.update(time: result)
    }
    
    private func prepareQueue(reference: Reference) -> Reference? {
        self.readVerseMetaData(reference: reference)
        MediaPlayState.update(url: reference.toString())
        if let next = self.tocAudioBible.nextChapter(reference: reference) {
            self.addNextChapter(reference: next)
            return next
        } else {
            return nil
        }
    }
    
    private func readVerseMetaData(reference: Reference) {
        let reader = MetaDataReader()
        reader.readVerseAudio(damid: self.version, sequence: reference.sequence, bookId: reference.book, chapter: reference.chapter, readComplete: {
            audioChapter in
            self.audioChapter = audioChapter
            print("PARSED DATA \(self.audioChapter?.toString())")
        })
    }
    
    private func addNextChapter(reference: Reference) {
        let s3Key = reference.getS3Key(damId: self.version, fileType: self.fileType)
        AwsS3.shared.preSignedUrlGET(
            s3Bucket: self.s3Bucket,
            s3Key: s3Key,
            expires: 3600,
            complete: { url in
                print("computed GET URL \(String(describing: url))")
                if let audioUrl = url {
                    let asset = AVAsset(url: audioUrl)
                    let playerItem = AVPlayerItem(asset: asset)
                    self.player?.insert(playerItem, after: nil)
                }
            }
        )
    }
}

