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

public class BibleReader : NSObject {
    
    let tocAudioBible: TOCAudioBible
    let s3Bucket: String
    let version: String
    let firstReference: Reference
    let fileType: String
    var audioChapter: TOCAudioChapter?
    var view: BibleReaderView?
    var player: AVQueuePlayer?
    
    init(tocBible: TOCAudioBible, version: String, reference: Reference, fileType: String) {
        self.tocAudioBible = tocBible
        self.s3Bucket = "audio-us-west-2-shortsands"
        self.version = version
        self.firstReference = reference
        self.fileType = fileType
    }
    
    deinit {
        if self.player != nil {
            self.player = nil
        }
        self.removeNotifications()
        print("Deinit BibleReader")
    }
    
    func setView(view: BibleReaderView) {
        self.view = view
    }
    
    public func beginStreaming() {
        let s3Key = self.firstReference.getS3Key(damId: self.version, fileType: self.fileType)
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
        let s3Key = self.firstReference.getS3Key(damId: self.version, fileType: self.fileType)
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
        let s3Key = self.firstReference.getS3Key(damId: self.version, fileType: self.fileType)
        filePath = filePath.appendingPathComponent(s3Key)
        print("FilePath \(filePath.absoluteString)")
        self.initAudio(url: filePath)
     }
    
    func initAudio(url: URL) {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        print("Player Item Status \(playerItem.status)")
        
        //let seekTime = backupSeek(state: self.currentState)
        //if (CMTimeGetSeconds(seekTime) > 0.1) {
        //    playerItem.seek(to: seekTime)
        //}
        self.player = AVQueuePlayer(items: [playerItem])
        self.player?.actionAtItemEnd = AVPlayerActionAtItemEnd.advance
        self.initNotifications()
        
        //delegate.completionHandler = complete
        //delegate.videoAnalytics = self.videoAnalytics
        //self.controller.delegate = delegate
        
        self.play()
        
        if let vue = self.view {
            let progressLink = CADisplayLink(target: vue, selector: #selector(vue.updateProgress))
            progressLink.add(to: .current, forMode: .defaultRunLoopMode)
            progressLink.preferredFramesPerSecond = 15
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemNewAccessLogEntry(note:)),
                                               name: .AVPlayerItemNewAccessLogEntry,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemTimeJumped(note:)),
                                               name: .AVPlayerItemTimeJumped,
                                               object: nil)
    }

    func removeNotifications() {
        print("\n ***** INSIDE REMOVE NOTIFICATIONS")
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemPlaybackStalled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemNewErrorLogEntry, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive, object: nil)
    }
    
    func playerItemDidPlayToEndTime(note:Notification) {
        print("\n** DID PLAY TO END \(String(describing: note.object))")
        //self.dismiss(animated: false) // move this till after??
        //sendVideoAnalytics(isStart: false, isDone: true)
        //VideoViewState.clear()
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
        //print("\n****** ACCESS LOG ENTRY \(String(describing: note.object))\n\(String(describing: self.player?.currentItem?.accessLog()))")
        
        let newReference = findBookChapter(noteObject: note.object)
        if let ref = newReference {
            readVerseMetaData(reference: ref)
            let nextReference = self.tocAudioBible.nextChapter(reference: ref)
            if let next = nextReference {
                self.addNextChapter(reference: next)
            }
        }
    }
    func playerItemTimeJumped(note:Notification) {
        //print("\n****** TIME JUMPED \(String(describing: note.object))")
    }
    /**
     * This method is called when the Home button is clicked or double clicked.
     * VideoState is saved in this method
     */
    func applicationWillResignActive(note:Notification) {
        print("\n******* APPLICATION WILL RESIGN ACTIVE *** in AVPlayerViewController")
        //sendVideoAnalytics(isStart: false, isDone: false)
        //VideoViewState.update(time: self.player?.currentTime())
    }
    
    private func findBookChapter(noteObject: Any?) -> Reference? {
        var items = [String]()
        if let item = noteObject as? AVPlayerItem {
            if let asset = item.asset as? AVURLAsset {
                let url = asset.url.path
                let parts = url.components(separatedBy: "?")
                let pieces = parts[0].components(separatedBy: "/")
                items = pieces.last?.components(separatedBy: ["_", "."]) ?? [String]()
            }
        }
        return (items.count > 3) ? Reference(sequence: items[1], book: items[2], chapter: items[3]) : nil
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

/*
 
 public class VideoViewPlayer : NSObject {
	
 public let controller = AVPlayerViewController()
 private let delegate = VideoViewControllerDelegate() // Without this delegate is lost because weak to controller
 
 let videoAnalytics: VideoAnalytics
 let currentState: VideoViewState // To help prevent GC
 
 public init(mediaSource: String,
        videoId: String,
        languageId: String,
        silLang: String,
        videoUrl: String) {
    print("INSIDE VideoViewPlayer \(videoId)  \(videoUrl)")
    self.currentState = VideoViewState.retrieve(videoId: videoId)
    self.currentState.videoUrl = videoUrl
    self.videoAnalytics = VideoAnalytics(mediaSource: mediaSource,
    mediaId: videoId,
    languageId: languageId,
    silLang: silLang)
 }
 
 deinit {
    print("VideoViewPlayer is deallocated.")
 }
 
 public func begin(complete: @escaping (_ error:Error?) -> Void) {
    print("VideoViewPlayer.BEGIN")
    let videoUrl: URL? = URL(string: self.currentState.videoUrl)
    if let url: URL = videoUrl {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        let seekTime = backupSeek(state: self.currentState)
        if (CMTimeGetSeconds(seekTime) > 0.1) {
            playerItem.seek(to: seekTime)
        }
        let player = AVPlayer(playerItem: playerItem)
 
        delegate.completionHandler = complete
        delegate.videoAnalytics = self.videoAnalytics
        self.controller.delegate = delegate
        self.controller.showsPlaybackControls = true
        self.controller.player = player
        self.controller.player?.play()
    }
 }
 
 func backupSeek(state: VideoViewState) -> CMTime {
    let duration: Int64 = Int64(Date().timeIntervalSince(state.timestamp))
    let backupSec: Int = String(duration).characters.count // could multiply by a factor here
    let backupTime: CMTime = CMTimeMake(Int64(backupSec), 1)
    return(CMTimeSubtract(state.position, backupTime))
 }
}

 
*/

