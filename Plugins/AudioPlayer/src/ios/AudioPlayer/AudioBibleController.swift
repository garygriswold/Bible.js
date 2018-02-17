//
//  AudioBibleViewController.swift
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
 
    var fileType: String
    var metaDataReader: AudioMetaDataReader?
    var audioBible: AudioBible?
    var audioBibleView: AudioBibleView?
    var audioSession: AudioSession?
    var completionHandler: ((Error?)->Void)?
    
    private init() {
        self.fileType = "mp3"
    }
    
    deinit {
        print("***** Deinit AudioBibleController *****")
    }
    
    public func findAudioVersion(version: String, silLang: String,
                                 complete: @escaping (_ bookList:String) -> Void) {
        self.metaDataReader = AudioMetaDataReader()
        metaDataReader!.read(versionCode: version, silLang: silLang,
                      complete: { oldTestament, newTestament in
                        var bookIdList = ""
                        if let oldTest = oldTestament {
                            bookIdList = oldTest.getBookList()
                        }
                        if let newTest = newTestament {
                            bookIdList += "," + newTest.getBookList()
                        }
                        complete(bookIdList)
            }
        )
    }
    
    /**
    * This must be set to be the WKWebView
    */
    public func present(view: UIView, book: String, chapterNum: Int, complete: @escaping (_ error:Error?) -> Void) {
  //      view.backgroundColor = .blue // This is for Testing
        
        self.audioBible = AudioBible.shared(controller: self)
        self.audioBibleView = AudioBibleView.shared(view: view, audioBible: self.audioBible!)
        self.audioSession = AudioSession.shared(audioBibleView: self.audioBibleView!)
        self.completionHandler = complete
        
        if let reader = metaDataReader {
            if let meta = reader.findBook(bookId: book) {
                let ref = AudioReference(bible: meta.bible, book: meta, chapterNum: chapterNum, fileType: self.fileType)
                self.audioBible!.beginReadFile(reference: ref)
            } else {
                complete(nil)
            }
        } else {
            complete(nil)
        }
    }
    
    func playHasStarted() {
        self.audioBibleView?.startPlay()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func playHasStopped() {
        self.audioBibleView?.stopPlay()
        UIApplication.shared.isIdleTimerDisabled = false
        self.completionHandler?(nil)
    }
}

