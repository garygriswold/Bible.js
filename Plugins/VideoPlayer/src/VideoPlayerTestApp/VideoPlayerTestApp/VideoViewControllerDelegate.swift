//
//  VideoViewControllerDelegate.swift
//  VideoPlayer
//
//  Created by Gary Griswold on 6/16/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import Foundation
import AVKit

class VideoViewControllerDelegate : NSObject, AVPlayerViewControllerDelegate {
    
    public var completionHandler: ((Error?)->Void)?
    public var videoAnalytics: VideoAnalytics?
    
}



