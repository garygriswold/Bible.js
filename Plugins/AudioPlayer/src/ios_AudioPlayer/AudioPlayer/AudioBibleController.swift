//
//  AudioBibleViewController.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/24/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import UIKit

class AudioBibleController {
    
    static let shared: AudioBibleController = AudioBibleController()
 
    var audioBible: AudioBible?
    var audioBibleView: AudioBibleView?
    var audioSession: AudioSession?
    
    private init() {
    }
    
    deinit {
        print("***** Deinit AudioBibleController *****")
    }
    
    /**
    * This must be set to be the WKWebView
    */
    func present(view: UIView, version: String, book: String, chapter: String, fileType: String) {
  //      view.backgroundColor = .blue // This is for Testing
        
        self.audioBible = AudioBible.shared(controller: self)
        self.audioBibleView = AudioBibleView.shared(view: view, audioBible: self.audioBible!)
        self.audioSession = AudioSession.shared(audioBibleView: self.audioBibleView!)
        
        let metaData = MetaDataReader()
        metaData.read(versionCode: version, complete: { [unowned self] oldTestament, newTestament in
            print("DONE reading metadata")
            if let meta = metaData.findBook(bookId: book) {
                let reference = Reference(bible: meta.bible, book: meta, chapter: chapter, fileType: fileType)
                self.audioBible!.beginReadFile(reference: reference)
            }
        })
    }
    
    func playHasStarted() {
        self.audioBibleView?.startPlay()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func playHasStopped() {
        self.audioBibleView?.stopPlay()
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

