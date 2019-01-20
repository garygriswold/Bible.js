//
//  AudioFauxAnalytics.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 1/20/19.
//  Copyright © 2019 ShortSands. All rights reserved.
//

import CoreMedia

/**
 * This class has the exact same signature as AudioAnalytics, but it does nothing.
 * It was writtent as a way to disable Audio Analytics without discarding the
 * real AudioAnalytics code.
 */
class AudioFauxAnalytics {
    
    init(mediaSource: String,
         mediaId: String,
         languageId: String,
         textVersion: String,
         silLang: String) {}
    
    func playStarted(item: String, position: CMTime) {}
    
    func playEnded(item: String, position: CMTime) {}
}
