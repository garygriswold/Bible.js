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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.controller.modalPresentationStyle = UIModalPresentationStyle.fullScreen // .formSheet
        //self.definesPresentationContext = true
        //self.modalTransitionStyle = UIModalTransitionStyle.coverVertical // this is redundant, which is needed
        //self.controller.modalTransitionStyle = UIModalTransitionStyle.coverVertical // I think the parent is controlling
        //self.present(self.controller, animated: true, completion: { print("VIEW COMPLETION")} ) // what else in completion
        // are formsheet dimensions required?
        //self.view.addSubview(self.controller.view)
        //self.view.addSubview(myView)
        self.view.backgroundColor = .blue
        
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
                    self.reader = AudioBible(tocBible: tocBible, version: "DEMO", reference: reference, fileType: "mp3")
                    if let read = self.reader {
                        self.readerView = AudioBibleView(controller: self, audioBible: read)
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
    
    // NOTE: I have never seen the Dismissed controller in output
    public func stopAudioPlayer() {
        self.dismiss(animated: true, completion: { print("Dismissed controller")})
        //self.removeFromParentViewController()
        if self.view != nil {
            self.view.removeFromSuperview()
            self.view = nil
        }
    }
}

