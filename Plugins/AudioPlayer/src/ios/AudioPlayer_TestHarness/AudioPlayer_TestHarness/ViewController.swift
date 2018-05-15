//
//  ViewController.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 7/31/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import UIKit
//#if USE_FRAMEWORK
//import AWS
import AudioPlayer
//#endif

class ViewController: UIViewController {
    
    let audioController = AudioBibleController.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        let readVersion = "WEB"//KJVPD"//ESV"
        let readLang = "eng"
        let readBook = "JHN"
        let readChapter = 2
        self.audioController.findAudioVersion(version: readVersion, silLang: readLang,
                                              complete: { bookIdList in
            print("BOOKS: \(bookIdList)")
                                                
            self.audioController.present(view: self.view, book: readBook,
                                         chapterNum: readChapter, complete: { error in
                                        print("ViewController.present did finish error: \(String(describing: error))")
            })
        })
        
//        let readBook2 = "MAT"
//        self.audioController.present(view: self.view, book: readBook2, chapterNum: readChapter,
//                                     complete: { error in }
//                                     )
//
//        let readBook3 = "EPH"
//        self.audioController.present(view: self.view, book: readBook3, chapterNum: readChapter,
//                                      complete: { error in }
//                                     )
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

