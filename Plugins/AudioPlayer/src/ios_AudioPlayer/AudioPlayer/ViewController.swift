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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        AwsS3.region = "us-east-1"
        //self.reader = BibleReader(audioFile: "ENGWEBN2DA-John-1.mp3")
        self.reader = BibleReader(version: "ENGWEBN2DA", book: "John", firstChapter: 1, lastChapter: 3, fileType: "mp3")
        self.reader?.createAudioPlayerUI(view: self.view)
        self.reader?.beginStreaming()
        //self.reader?.beginDownload()
        //self.reader?.beginLocal()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

