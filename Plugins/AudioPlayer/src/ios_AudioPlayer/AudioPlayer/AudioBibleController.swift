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
    //static let shared: AudioBibleController = AudioBibleController()
 
    var audioBible: AudioBible?
    var audioBibleView: AudioBibleView?
    var audioSession: AudioSession?
    var completionHandler: ((Error?)->Void)?
    
    private init() {
    }
    
    deinit {
        print("***** Deinit AudioBibleController *****")
    }
    
    /**
    * This must be set to be the WKWebView
    */
    public func present(view: UIView, version: String, silLang: String, book: String, chapter: String, fileType: String,
                 complete: @escaping (_ error:Error?) -> Void) {
  //      view.backgroundColor = .blue // This is for Testing
        
        self.audioBible = AudioBible.shared(controller: self)
        self.audioBibleView = AudioBibleView.shared(view: view, audioBible: self.audioBible!)
        self.audioSession = AudioSession.shared(audioBibleView: self.audioBibleView!)
        self.completionHandler = complete
        
        let metaData = MetaDataReader()
        metaData.read(versionCode: version, silLang: silLang, complete: { [unowned self] oldTestament, newTestament in
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
        self.completionHandler?(nil)
    }
}

