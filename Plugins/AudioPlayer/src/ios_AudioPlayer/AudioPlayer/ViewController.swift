//
//  ViewController.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 7/31/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import UIKit
import AWS

class ViewController: UIViewController {
    
    var reader: BibleReader?
    var readerView: BibleReaderView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                    self.reader = BibleReader(tocBible: tocBible, version: "DEMO", reference: reference, fileType: "mp3")
                    if let read = self.reader {
                        self.readerView = BibleReaderView(view: self.view, bibleReader: read)
                        if let vue = self.readerView {
                            //vue.createAudioPlayerUI(view: self.view)
                            read.setView(view: vue)
                        
                            read.beginStreaming()
                            //read.beginDownload()
                            //read.beginLocal()
                        }
                    }
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

