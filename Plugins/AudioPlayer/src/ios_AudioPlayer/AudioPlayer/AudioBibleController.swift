//
//  AudioBibleViewController.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/24/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import Foundation
import AWS

class AudioBibleController {
    
    var readerView: AudioBibleView?
    
    deinit {
        print("***** Deinit AudioBibleController *****")
    }
    
    /**
    * This must be set to be the WKWebView
    */
    func present(view: UIView) {
        view.backgroundColor = .blue // This is for Testing
        
        AwsS3.region = "us-west-2"
        let metaData = MetaDataReader()
        metaData.read(languageCode: "ENG", mediaType: "audio", readComplete: { tocDictionary in
            
            //let tocAudioBible = tocDictionary["ENGWEBN2DA"]
            let tocAudioBible = tocDictionary["DEMO"]
            if let tocBible = tocAudioBible {
                //let metaBook = tocBible.booksById["JHN"]
                let metaBook = tocBible.booksById["TST"]
                if let book = metaBook {
                    
                    let reference = Reference(damId: tocBible.damId, sequence: book.sequence, book: book.bookId,
                                              chapter: "001", fileType: "mp3")
                    let reader = AudioBible(controller: self, tocBible: tocBible, reference: reference)
                    self.readerView = AudioBibleView(view: view, audioBible: reader)
                            
                    reader.beginStreaming()
                    //reader.beginDownload()
                    //reader.beginLocal()
                }
            }
        })
    }
    
    func playHasStarted() {
        self.readerView?.startPlay()
    }
    func playHasStopped() {
        self.readerView?.stopPlay()
        self.readerView = nil
    }
}

