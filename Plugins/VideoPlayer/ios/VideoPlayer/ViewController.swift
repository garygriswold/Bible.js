//
//  ViewController.swift
//  VideoPlayer
//
//  Created by Gary Griswold on 1/16/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//
import UIKit

class ViewController : UIViewController {
    
    var player: VideoPlayer?
    var hasLoaded: Bool = false
    
    override func loadView() {
        super.loadView()
        //let videoUrl: String = "https://s3.amazonaws.com/video-proto-out/andhls_0740.mp4.m3u8"
        let videoUrl: String = "https://arc.gt/jy7bi?apiSessionId=5880542ea3ec81.60338491"
        let seek: Int64 = 0
        self.player = VideoPlayer(videoUrl: videoUrl, seekTime: seek)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("VIEW DID LOAD in ViewController")
    }
    override func viewDidAppear(_ bool: Bool) {
        super.viewDidAppear(bool)
        print("VIEW DID APPEAR")
        if (!self.hasLoaded) {
            self.hasLoaded = true
            self.present(self.player!.controller, animated: true)
            self.player!.begin()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("did Receive Memory Warning in ViewController")
        // Dispose of any resources that can be recreated.
    }
}



