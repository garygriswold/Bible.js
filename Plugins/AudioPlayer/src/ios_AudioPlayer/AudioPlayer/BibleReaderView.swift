//
//  BibleReaderView.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/7/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class BibleReaderView : NSObject {
    
    let view: UIView
    let bibleReader: BibleReader
    
    var scrubSlider: UISlider?
    // Transient State Variable
    var scrubSliderDuration: CMTime
    var scrubSliderDrag: Bool
    
    init(view: UIView, bibleReader: BibleReader) {
        self.view = view
        self.bibleReader = bibleReader
        self.scrubSliderDuration = kCMTimeZero
        self.scrubSliderDrag = false
    }
    
    deinit {
        print("BibleReaderView is deallocated")
        // Do I need to remove listeners from controls here
    }
    
    func createAudioPlayerUI(view: UIView) {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        let playButton = UIButton(type: .custom)
        playButton.frame = CGRect(x: screenWidth/3-25, y: 100, width: 50, height: 50)
        playButton.layer.cornerRadius = 0.5 * playButton.bounds.size.width
        playButton.backgroundColor = .green
        playButton.setTitle("Play", for: .normal)
        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
        self.view.addSubview(playButton)
        
        let pauseButton = UIButton(type: .custom)
        pauseButton.frame = CGRect(x: screenWidth*2/3-25, y: 100, width: 50, height: 50)
        pauseButton.layer.cornerRadius = 0.5 * pauseButton.bounds.size.width
        pauseButton.backgroundColor = .red
        pauseButton.setTitle("Pause", for: .normal)
        pauseButton.addTarget(self, action: #selector(pause), for: .touchUpInside)
        self.view.addSubview(pauseButton)
        
        let scrubRect = CGRect(x: screenWidth * 0.05, y: 200, width: screenWidth * 0.9, height: 100)
        let scrub = UISlider(frame: scrubRect)
        scrub.isContinuous = false
        scrub.minimumTrackTintColor = UIColor.green
        scrub.maximumTrackTintColor = UIColor.purple
        scrub.value = 0
        scrub.addTarget(self, action: #selector(scrubSliderChanged), for: .valueChanged)
        scrub.addTarget(self, action: #selector(touchDown), for: .touchDown)
        scrub.addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
        
        self.view.addSubview(scrub)
        self.scrubSlider = scrub
    }
    
    func play() {
        self.bibleReader.play()
    }
    
    func pause() {
        self.bibleReader.pause()
    }
    
    /**
    * Scrub Slider Animation
    */
    public func updateProgress(displaylink: CADisplayLink) {
        if self.scrubSliderDrag { return }
        
        if let item = self.bibleReader.player?.currentItem {
            if CMTIME_IS_NUMERIC(item.duration) {
                if item.duration != self.scrubSliderDuration {
                    self.scrubSliderDuration = item.duration
                    let duration = CMTimeGetSeconds(item.duration)
                    self.scrubSlider?.maximumValue = Float(duration)
                }
            }
            let current = CMTimeGetSeconds(item.currentTime())
            self.scrubSlider?.setValue(Float(current), animated: true)
        }
    }
    
    /**
    * Scrub Slider Event Handler
    */
    func scrubSliderChanged(sender: UISlider, forEvent event: UIEvent) {
        if let slider = self.scrubSlider {
            print("scrub slider changed to \(slider.value)")
            if let play = self.bibleReader.player {
                if (slider.value < slider.maximumValue) {
                    let time: CMTime = CMTime(seconds: Double(slider.value), preferredTimescale: CMTimeScale(1.0))
                    play.seek(to: time)
                } else {
                    play.advanceToNextItem()
                }
            }
        }
    }
    func touchDown() {
        print("**** touchDown ***")
        self.scrubSliderDrag = true
    }
    func touchUpInside() {
        print("**** touchUpInside ***")
        self.scrubSliderDrag = false
    }
 }
