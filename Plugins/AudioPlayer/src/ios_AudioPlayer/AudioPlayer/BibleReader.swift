//
//  BibleReader.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 7/31/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import Foundation
import AVFoundation

public class BibleReader {
    
    var player: AVAudioPlayer?
    
    init() {

    }
    
    deinit {
        if self.player != nil {
            self.player?.stop()
            self.player = nil
        }
        print("Deinit BibleReader")
    }
    
    func start() {
        let path = Bundle.main.path(forResource: "EmmaFirstLostTooth", ofType: "mp3")
        //let path = Bundle.main.path(forResource: "audioFile", ofType: "mp3")
        let url = URL(fileURLWithPath: path!)
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
        } catch let err {
            print("Sound failed to play \(err)")
        }
        if let reader = self.player {
            reader.prepareToPlay()
            //reader.delegate = self as AVAudioPlayerDelegate
            reader.play()
        }
    }
    
}

