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

class AudioBibleView : NSObject {
    
    let view: UIView
    let audioBible: AudioBible
    let playButton: UIButton
    let pauseButton: UIButton
    let stopButton: UIButton
    let scrubSlider: UISlider
    let verseLabel: UILabel
    var progressLink: CADisplayLink?
    // Transient State Variables
    var scrubSliderDuration: CMTime
    var scrubSliderDrag: Bool
    var isAudioViewActive: Bool = false
    
    init(view: UIView, audioBible: AudioBible) {
        self.view = view
        self.audioBible = audioBible
        self.scrubSliderDuration = kCMTimeZero
        self.scrubSliderDrag = false

        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        let playBtn = UIButton(type: .custom)
        playBtn.frame = CGRect(x: screenWidth/3-40, y: 100, width: 80, height: 80)
        let playUpImg = UIImage(named: "Images/PlayUPButton.png")
        playBtn.setImage(playUpImg, for: UIControlState.normal)
        let playDnImg = UIImage(named: "Images/PlayDNButton.png")
        playBtn.setImage(playDnImg, for: UIControlState.highlighted)
        self.playButton = playBtn
        
        let pauseBtn = UIButton(type: .custom)
        pauseBtn.frame = CGRect(x: screenWidth/3-40, y: 100, width: 80, height: 80)
        let pauseUpImg = UIImage(named: "Images/PauseUPButton.png")
        pauseBtn.setImage(pauseUpImg, for: UIControlState.normal)
        let pauseDnImg = UIImage(named: "Images/PauseDNButton.png")
        pauseBtn.setImage(pauseDnImg, for: UIControlState.highlighted)
        self.view.addSubview(pauseBtn)
        self.pauseButton = pauseBtn
        
        let stopBtn = UIButton(type: .custom)
        stopBtn.frame = CGRect(x: screenWidth*2/3-40, y: 100, width: 80, height: 80)
        let stopUpImg = UIImage(named: "Images/StopUPButton.png")
        stopBtn.setImage(stopUpImg, for: UIControlState.normal)
        let stopDnImg = UIImage(named: "Images/StopDNButton.png")
        stopBtn.setImage(stopDnImg, for: UIControlState.highlighted)
        self.view.addSubview(stopBtn)
        self.stopButton = stopBtn
        
        let scrubRect = CGRect(x: screenWidth * 0.05, y: 230, width: screenWidth * 0.9, height: 60)
        let scrub = UISlider(frame: scrubRect)
        scrub.isContinuous = false
        let thumbUpImg = UIImage(named: "Images/ThumbUP.png")
        scrub.setThumbImage(thumbUpImg, for: UIControlState.normal)
        let thumbDnImg = UIImage(named: "Images/ThumbDN.png")
        scrub.setThumbImage(thumbDnImg, for: UIControlState.highlighted)
        
        let sliderMinImg = UIImage(named: "Images/SliderMin.png")
        let sliderMinInsets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
        let sliderMin = sliderMinImg?.resizableImage(withCapInsets: sliderMinInsets,
                                                     resizingMode: UIImageResizingMode.stretch)
        scrub.setMinimumTrackImage(sliderMin, for: UIControlState.normal)
        
        let sliderMaxImg = UIImage(named: "Images/SliderMax.png")
        let sliderMaxInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 8.0)
        let sliderMax = sliderMaxImg?.resizableImage(withCapInsets: sliderMaxInsets,
                                                     resizingMode: UIImageResizingMode.stretch)
        scrub.setMaximumTrackImage(sliderMax, for: UIControlState.normal)
        
        scrub.setValue(0.0, animated: false)
        self.view.addSubview(scrub)
        self.scrubSlider = scrub
        
        let verse = UILabel()
        verse.frame = CGRect(x: screenWidth * 0.05, y: 195, width: 30, height: 30)
        verse.text = "1"
        verse.font = UIFont(name: "Helvetica Neue", size: 12)
        verse.textColor = UIColor.black
        verse.backgroundColor = UIColor.white
        verse.textAlignment = NSTextAlignment.center
        verse.isUserInteractionEnabled = false
        verse.layer.borderColor = UIColor.black.cgColor
        verse.layer.borderWidth = 1.0
        // These 4 statements are supposted to produce a shadow
        verse.layer.shadowOpacity = 1.0;
        verse.layer.shadowRadius = 0.0;
        verse.layer.shadowColor = UIColor.black.cgColor
        verse.layer.shadowOffset = CGSize(width: 0.0, height: -1.0)
        
        self.view.addSubview(verse)
        self.verseLabel = verse
    }
    
    deinit {
        print("***** Deinit AudioBibleView *****")
    }
    
    func play() {
        self.audioBible.play()
        if (self.isAudioViewActive) {
            self.playButton.removeFromSuperview()
            self.view.addSubview(self.pauseButton)
        }
    }
    
    func pause() {
        self.audioBible.pause()
        if (self.isAudioViewActive) {
            self.pauseButton.removeFromSuperview()
            self.view.addSubview(self.playButton)
        }
    }
    
    func stop() {
        self.audioBible.updateMediaPlayStateTime()
        self.audioBible.sendAudioAnalytics()
        self.audioBible.stop()
    }
    
    func startPlay() {
        self.isAudioViewActive = true
        self.progressLink = CADisplayLink(target: self, selector: #selector(updateProgress))
        self.progressLink!.add(to: .current, forMode: .defaultRunLoopMode)
        self.progressLink!.preferredFramesPerSecond = 15
        
        self.playButton.addTarget(self, action: #selector(self.play), for: .touchUpInside)
        self.pauseButton.addTarget(self, action: #selector(self.pause), for: .touchUpInside)
        self.stopButton.addTarget(self, action: #selector(self.stop), for: .touchUpInside)
        self.scrubSlider.addTarget(self, action: #selector(scrubSliderChanged), for: .valueChanged)
        self.scrubSlider.addTarget(self, action: #selector(touchDown), for: .touchDown)
        self.scrubSlider.addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
    }
    
    func stopPlay() {
        self.isAudioViewActive = false
        self.playButton.removeFromSuperview()
        self.pauseButton.removeFromSuperview()
        self.stopButton.removeFromSuperview()
        self.scrubSlider.removeFromSuperview()
        self.verseLabel.removeFromSuperview()
        self.progressLink?.invalidate()
    }
    
    /**
    * Scrub Slider Animation
    */
    func updateProgress() {
        if self.scrubSliderDrag { return }
        
        if let item = self.audioBible.player?.currentItem {
            if CMTIME_IS_NUMERIC(item.duration) {
                if item.duration != self.scrubSliderDuration {
                    self.scrubSliderDuration = item.duration
                    let duration = CMTimeGetSeconds(item.duration)
                    self.scrubSlider.maximumValue = Float(duration)
                }
            }
            let current = CMTimeGetSeconds(item.currentTime())
            self.scrubSlider.setValue(Float(current), animated: true)
            
            let xPixel = xPositionSeekBar()
            self.verseLabel.center = CGPoint(x: xPixel, y: 210)
            self.verseLabel.text = String(describing: Int(xPixel / 100) + 1)
            
        }
    }
    private func xPositionSeekBar() -> CGFloat {
        let slider = self.scrubSlider
        let sliderRange: CGFloat = slider.frame.size.width - (slider.currentThumbImage?.size.width)! /// PRECOMPUTE
        let sliderOrigin: CGFloat = slider.frame.origin.x + ((slider.currentThumbImage?.size.width)! / 2.0) /// PRECOMPUTE
        let sliderPct: Float = (slider.value - slider.minimumValue) / (slider.maximumValue - slider.minimumValue)
        let sliderValueToPixels: CGFloat = (CGFloat(sliderPct) * sliderRange) + sliderOrigin
        return sliderValueToPixels;
    }
    
    /**
    * Scrub Slider Event Handler
    */
    func scrubSliderChanged(sender: UISlider, forEvent event: UIEvent) {
        let slider = self.scrubSlider
        print("scrub slider changed to \(slider.value)")
        if let play = self.audioBible.player {
            if (slider.value < slider.maximumValue) {
                var current: Float
                if let verse = self.audioBible.audioChapter {
                    current = verse.findVerseByPosition(seconds: slider.value)
                } else {
                    current = slider.value
                }
                let time: CMTime = CMTime(seconds: Double(current), preferredTimescale: CMTimeScale(1.0))
                play.seek(to: time)
            } else {
                self.audioBible.advanceToNextItem()
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
