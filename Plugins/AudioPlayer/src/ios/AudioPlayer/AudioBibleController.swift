//
//  AudioBibleController.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/24/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import UIKit

public class AudioBibleController {
    
    private static var instance: AudioBibleController?
    public static var shared: AudioBibleController {
        get {
            if AudioBibleController.instance == nil {
                AudioBibleController.instance = AudioBibleController()
            }
            return AudioBibleController.instance!
        }
    }
 
    var audioTOCBible: AudioTOCBible?
    private var fileType: String
    private var audioBible: AudioBible?
    private var audioBibleView: AudioBibleView?
    private var audioSession: AudioSession?
    private var completionHandler: ((Error?)->Void)?
    
    private init() {
        self.fileType = "mp3"
        print("***** Init AudioBibleController *****")
    }
    
    deinit {
        print("***** Deinit AudioBibleController *****")
    }
    
    public func findAudioVersion(bibleId: String, iso3: String,
                                 audioBucket: String?, otDamId: String?, ntDamId: String?) -> String {
        self.audioTOCBible = AudioTOCBible(source: "FCBH", bibleId: bibleId, iso3: iso3,
                                            audioBucket: audioBucket, otDamId: otDamId, ntDamId: ntDamId)
        return self.audioTOCBible!.read()
    }
    
    public func isPlaying() -> Bool {
        var result:Bool = false
        if let play = self.audioBible {
            if let view = self.audioBibleView {
                result = play.isPlaying() || view.audioBibleActive()
            }
        }
        return result
    }
    
    /**
    * This is the entry point to start the Audio Player.  But, findAudioVersion must be called first
    * in order to set the bucket and damId, and read in the metadata for the damId.
    */
    public func present(view: UIView, book: String, chapterNum: Int, complete: @escaping (_ error:Error?) -> Void) {
        self.audioBible = AudioBible.shared(controller: self)
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
                    self.audioBible!.beginReadFile(reference: ref)
                } else { complete(nil) }
            } else { complete(nil) }
        } else { complete(nil) }
    }
    
    public func dismiss() {
        if self.audioBible!.isPlaying() {
            self.audioBible!.stop()
        }
        if self.audioBibleView!.audioBibleActive() {
            self.audioBibleView!.dismissPlayer()
        }
    }
    /**
    * This is called when the Audio must be stopped externally, such as when a Video is started.
    */
    public func stop() {
        self.audioBible?.stop()
    }
}

