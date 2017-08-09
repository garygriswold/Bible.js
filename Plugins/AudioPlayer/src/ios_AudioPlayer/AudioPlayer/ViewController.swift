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
        // Do any additional setup after loading the view, typically from a nib.
        
        AwsS3.region = "us-west-2"
        let metaData = MetaDataReader(languageCode: "ENG", mediaType: "audio")
        metaData.read(readComplete: { metaData in
            
            let engWeb = metaData["ENGWEBN2DA"]
            print("WEB: \(String(describing:(engWeb?.toString())))")
            let book = engWeb?.books["John"]
            print("BOOK: \(String(describing:(book?.toString())))")
            let lastChapter = book?.numberOfChapters
            print("CHAPTER: \(String(describing:(lastChapter)))")
            //self.reader = BibleReader(audioFile: "ENGWEBN2DA-John-1.mp3")
            self.reader = BibleReader(version: "ENGWEBN2DA", book: "John", firstChapter: 1, lastChapter: 3,
                                      fileType: "mp3")
            if let read = self.reader {
                self.readerView = BibleReaderView(view: self.view, bibleReader: read)
                self.readerView?.createAudioPlayerUI(view: self.view)
                read.beginStreaming()
                //read.beginDownload()
                //read.beginLocal()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

