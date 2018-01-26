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
    
    let audioController = AudioBibleController()

    override func viewDidLoad() {
        super.viewDidLoad()
        AwsS3.region = "us-east-1"
        let readVersion = "KJVPD"//ESV"
        let readBook = "JHN"
        let readChapter = "002"
        let readType = "mp3"
        self.audioController.present(view: self.view, version: readVersion, book: readBook, chapter: readChapter,
                                     fileType: readType)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("****** viewWillDisappear *****")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("****** viewDidDisappear *****")
    }
}

