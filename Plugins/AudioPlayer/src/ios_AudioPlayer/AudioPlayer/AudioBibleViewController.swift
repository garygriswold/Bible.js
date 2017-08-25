//
//  AudioBibleViewController.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/24/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import Foundation
import UIKit
import AWS

class AudioBibleViewController : UIViewController {
    
    var reader: AudioBible?
    var readerView: AudioBibleView?
    
    /**
    * This must be set to be the WKWebView
    */
    func setView(view: UIView) {
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .blue // This is for Testing
        
        AwsS3.region = "us-west-2"
        let metaData = MetaDataReader()
        metaData.read(languageCode: "ENG", mediaType: "audio", readComplete: { tocDictionary in
            
            //let tocAudioBible = tocDictionary["ENGWEBN2DA"]
            let tocAudioBible = tocDictionary["DEMO"]
            if let tocBible = tocAudioBible {
                //let metaBook = tocBible.booksById["JHN"]
                let metaBook = tocBible.booksById["TST"]
                if let book = metaBook {
                    
                    let reference = Reference(sequence: book.sequence, book: book.bookId, chapter: "001")
                    self.reader = AudioBible(controller: self, tocBible: tocBible,
                                             version: "DEMO", reference: reference, fileType: "mp3")
                    if let read = self.reader {
                        self.readerView = AudioBibleView(controller: self, audioBible: read)
                            
                        read.beginStreaming()
                        //read.beginDownload()
                        //read.beginLocal()
                    }
                }
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playHasStarted() {
        self.readerView?.startPlay()
    }
    func playHasStopped() {
        self.readerView?.stopPlay()
    }
}

