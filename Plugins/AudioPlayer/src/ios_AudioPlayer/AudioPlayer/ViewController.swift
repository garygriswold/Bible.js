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
        metaData.read(languageCode: "ENG", mediaType: "audio", readComplete: { data in
            
            let metaData = data["ENGWEBN2DA"]
            if let meta = metaData {
                let metaBook = meta.books["JHN"]
                if let book = metaBook {
                    
                    // It would be nice to get the information from meta data here, but it is wrong meta data
                    //self.reader = BibleReader(version: meta.damId, sequence: book.sequence, book: book.bookId,
                    //                          firstChapter: "001", lastChapter: "003", fileType: "mp3")
                    let reference = Reference(sequence: "01", book: "TST", chapter: "001")
                    self.reader = BibleReader(version: "DEMO", reference: reference, fileType: "mp3")
                    if let read = self.reader {
                        self.readerView = BibleReaderView(view: self.view, bibleReader: read)
                        self.readerView?.createAudioPlayerUI(view: self.view)
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
}

