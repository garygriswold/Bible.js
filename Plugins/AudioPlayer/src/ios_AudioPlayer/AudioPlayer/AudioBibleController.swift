//
//  AudioBibleViewController.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/24/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import UIKit

class AudioBibleController {
    
    var audioSession: AudioSession?
    var readerView: AudioBibleView?
    
    deinit {
        print("***** Deinit AudioBibleController *****")
    }
    
    /**
    * This must be set to be the WKWebView
    */
    func present(view: UIView, version: String, book: String, chapter: String, fileType: String) {
  //      view.backgroundColor = .blue // This is for Testing
        
        let metaData = MetaDataReader()
        metaData.read(versionCode: version, complete: { oldTestament, newTestament in
            print("DONE reading metadata")
            let metaBook = metaData.findBook(bookId: book)
            if let book = metaBook {
                let tocBible = book.bible
                let reference = Reference(damId: tocBible.damId, sequence: book.bookOrder,
                                          book: book.bookId,
                                          bookName: book.bookName, chapter: chapter, fileType: fileType)
                let reader = AudioBible(controller: self, tocBible: tocBible, reference: reference)
                self.readerView = AudioBibleView(view: view, audioBible: reader)
                self.audioSession = AudioSession(audioBibleView: self.readerView!)
                reader.beginReadFile()
            }
        })
    }
    
    func playHasStarted() {
        self.readerView?.startPlay()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func playHasStopped() {
        self.readerView?.stopPlay()
        self.readerView = nil
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

