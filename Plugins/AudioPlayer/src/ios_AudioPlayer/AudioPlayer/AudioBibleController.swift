//
//  AudioBibleViewController.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/24/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import UIKit

class AudioBibleController {
 
    var audioBible: AudioBible?
    var readerView: AudioBibleView?
    var audioSession: AudioSession?

    
    deinit {
        print("***** Deinit AudioBibleController *****")
    }
    
    /**
    * This must be set to be the WKWebView
    */
    func present(view: UIView, version: String, book: String, chapter: String, fileType: String) {
  //      view.backgroundColor = .blue // This is for Testing
        
        self.audioBible = AudioBible.shared(controller: self)
        
        let metaData = MetaDataReader()
        metaData.read(versionCode: version, complete: { [unowned self] oldTestament, newTestament in
            print("DONE reading metadata")
            if let meta = metaData.findBook(bookId: book) {
                let reference = Reference(bible: meta.bible, book: meta, chapter: chapter, fileType: fileType)
                self.readerView = AudioBibleView(view: view, audioBible: self.audioBible!)
                self.audioSession = AudioSession(audioBibleView: self.readerView!)
                self.audioBible!.beginReadFile(reference: reference)
            }
        })
    }
    
    func playHasStarted() {
        self.readerView?.startPlay()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func playHasStopped() {
        self.readerView?.stopPlay()
        self.audioSession = nil
        self.readerView = nil
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

