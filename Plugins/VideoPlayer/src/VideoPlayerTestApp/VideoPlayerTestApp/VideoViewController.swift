/**
 *  ViewController.swift
 *  VideoPlayer
 *
 *  Created by Gary Griswold on 1/16/17.
 *  Copyright © 2017 ShortSands. All rights reserved.
 *
 * *** This class is deprecated.  It was needed to write a
 * standalone video player application, but it is not part of the
 * videoplayer plugin.
 */
import UIKit
import VideoPlayer

class VideoViewController : UIViewController {
    
    var videoViewPlayer: VideoViewPlayer?
    var hasLoaded: Bool = false
    
    override func loadView() {
        super.loadView()
        print("\n****** loadView in VideoViewController")
        //let videoUrl: String = "https://s3.amazonaws.com/video-proto-out/andhls_0740.mp4.m3u8" // Emmy
        //let videoUrl: String = "https://arc.gt/jy7bi?apiSessionId=5880542ea3ec81.60338491" // Jesus for Children
        let videoUrl: String = "https://arc.gt/1e62h?apiSessionId=587858aea460f2.62190595" // Jesus Film
        //let seekSec: Int64 = 0
        self.videoViewPlayer = VideoViewPlayer(videoId: "Jesus", videoUrl: videoUrl)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\n****** ViewDidLoad in VideoViewController")
    }
    override func viewDidAppear(_ bool: Bool) {
        super.viewDidAppear(bool)
        print("\n****** ViewDidAppear in VideoViewController")
        if (!self.hasLoaded) {
            self.hasLoaded = true
            self.present(self.videoViewPlayer!.controller, animated: true)
            self.videoViewPlayer!.begin(complete: { error in
                if let err = error {
                    print("Error in VideoPlayer \(String(describing: err))")
                } else {
                    print("Success in VideoPlayer")
                }
            })
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("\n****** DidReceiveMemoryWarning in VideoViewController")
        // Dispose of any resources that can be recreated.
    }
    func releaseVideoPlayer() {
        print("\n****** releaseViewController in VideoViewController")
        self.videoViewPlayer?.controller.dismiss(animated: false)
        self.videoViewPlayer = nil
    }
 }



