//
//  AudioBibleController.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/24/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import UIKit
import AWS

public class AudioBibleController {
    
    public static let TEXT_PAGE_CHANGED = NSNotification.Name("text-page-changed")
    public static let AUDIO_CHAP_CHANGED = NSNotification.Name("audio-chap-changed")
    
    public static var shared = AudioBibleController()
 
    var audioTOCBible: AudioTOCBible?
    private let fileType: String
    private var audioBible: AudioBible? // must be optional, because self is passed in init
    private var audioBibleView: AudioBibleView?
    private var audioSession: AudioSession?
    private var completionHandler: ((Error?)->Void)?
    
    private init() {
        self.fileType = "mp3"
        self.audioBible = AudioBible.shared(controller: self)
        let notify = NotificationCenter.default
        notify.addObserver(self, selector: #selector(textPageChanged(note:)),
                           name: AudioBibleController.TEXT_PAGE_CHANGED, object: nil)
        notify.addObserver(self, selector: #selector(applicationWillEnterForeground(note:)),
                           name: UIApplication.willEnterForegroundNotification, object: nil)
        print("***** Init AudioBibleController *****")
    }
    
    deinit {
        print("***** Deinit AudioBibleController *****")
    }
    
    /**
    * This function is called to see if Bible has changed, so that we need to reload meta data
    */
    public func isBibleChanged(bibleId: String) -> Bool {
        return self.audioTOCBible == nil || self.audioTOCBible!.bibleId != bibleId
    }
    
    /**
    * This function must be called before present, because it loads the metadata from the damId
    */
    public func findAudioVersion(bibleId: String, bibleName: String, iso3: String,
                                 audioBucket: String?, otDamId: String?, ntDamId: String?) -> String {
        self.audioTOCBible = AudioTOCBible(bibleId: bibleId, bibleName: bibleName, iso3: iso3,
                                           audioBucket: audioBucket, otDamId: otDamId,
                                           ntDamId: ntDamId)
        return self.audioTOCBible!.read()
    }
    
    public func isPlaying() -> Bool {
        if let play = self.audioBible {
            if let view = self.audioBibleView {
                return play.isPlaying() || view.audioBibleActive()
            }
        }
        return false
    }
    
    /**
    * This is the entry point to start the Audio Player.  But, findAudioVersion must be called first
    * in order to set the bucket and damId, and read in the metadata for the damId.
    */
    public func present(view: UIView, book: String, chapterNum: Int, complete: @escaping (_ error:Error?) -> Void) {
        self.audioBibleView = AudioBibleView.shared(view: view, audioBible: self.audioBible!)
        self.audioSession = AudioSession.shared(audioBibleView: self.audioBibleView!)
        self.completionHandler = complete
        
        if !self.audioBibleView!.audioBibleActive() {
            self.audioBibleView!.presentPlayer()
        }
        
        if !self.audioBible!.isPlaying() {
            if let reader = self.audioTOCBible {
                if let meta = reader.findBook(bookId: book) {
                    let ref = AudioReference(book: meta, chapterNum: chapterNum, fileType: self.fileType)
                    self.audioBible!.beginReadFile(reference: ref, start: false,
                                                   complete: {_ in })
                    // Note: The 'complete' in beginReadFile is when audio load is complete
                    // While the complete in present is when the audio is finished
                } else { complete(nil) }
            } else { complete(nil) }
        } else { complete(nil) }
    }
    
    public func carPlayPlayer(book: String, chapterNum: Int, start: Bool,
                              complete: @escaping (Error?) -> Void) {
        if let reader = self.audioTOCBible {
            if let meta = reader.findBook(bookId: book) {
                let ref = AudioReference(book: meta, chapterNum: chapterNum, fileType: self.fileType)
                self.audioBible!.beginReadFile(reference: ref, start: start, complete: complete)
            }
        }
    }
    
    public func hasCache(book: String, chapterNum: Int) -> Bool {
        if let reader = self.audioTOCBible {
            if let meta = reader.findBook(bookId: book) {
                let ref = AudioReference(book: meta, chapterNum: chapterNum, fileType: self.fileType)
                return AwsS3Cache.shared.hasFile(s3Bucket: ref.getS3Bucket(), s3Key: ref.getS3Key())
            }
        }
        return false
    }
    
    public func dismiss() {
        if self.audioBible != nil && self.audioBible!.isPlaying() {
            self.audioBible!.stop()
        }
        if self.audioBibleView != nil && self.audioBibleView!.audioBibleActive() {
            DispatchQueue.main.async {
                self.audioBibleView!.dismissPlayer()
            }
        }
        self.completionHandler!(nil)
    }
    /**
    * This is called when the Audio must be stopped externally, such as when a Video is started.
    */
    public func stop() {
        self.audioBible?.stop()
    }
    /**
    * This is called by AudioBible, when audio is ready to play
    */
    func audioReadyToPlay(enabled: Bool) {
        if self.audioBibleView != nil {
            DispatchQueue.main.async(execute: {
                self.audioBibleView!.audioReadyToPlay(enabled: enabled)
            })
        }
    }
    
    @objc func textPageChanged(note: NSNotification) {
        if self.audioBibleView != nil && self.audioBibleView!.audioBibleActive() {
            if self.audioBible == nil || !self.audioBible!.isPlaying() {
                self.dismiss()
            }
        }
    }
    
    @objc private func applicationWillEnterForeground(note: Notification) {
        print("\n****** APP WILL ENTER FOREGROUND IN VIEW \(Date().timeIntervalSince1970)")
        if self.audioBible != nil && self.audioBible!.isPlaying() {
            self.audioBibleView?.presentPlayer()
        } else {
            self.audioBibleView?.setPlayButtonPlay(play: true)
        }
    }
}


