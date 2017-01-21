//
//  ViewController.swift
//  VideoPlayer
//
//  Created by Gary Griswold on 1/16/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//
import UIKit

class ViewController : UIViewController {
    
    var videoPlayer: VideoPlayer?
    var hasLoaded: Bool = false
    
    override func loadView() {
        super.loadView()
        //let videoUrl: String = "https://s3.amazonaws.com/video-proto-out/andhls_0740.mp4.m3u8"
        let videoUrl: String = "https://arc.gt/jy7bi?apiSessionId=5880542ea3ec81.60338491"
        let seekSec: Int64 = 0
        self.videoPlayer = VideoPlayer(videoUrl: videoUrl, seekTime: seekSec)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\n****** ViewDidLoad in ViewController")
    }
    override func viewDidAppear(_ bool: Bool) {
        super.viewDidAppear(bool)
        print("\n****** ViewDidAppear in ViewController")
        if (!self.hasLoaded) {
            self.hasLoaded = true
            self.present(self.videoPlayer!.controller, animated: true)
            self.videoPlayer!.begin()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("\n****** DidReceiveMemoryWarning in ViewController")
        // Dispose of any resources that can be recreated.
    }
}



