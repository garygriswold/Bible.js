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
    let verseLabel: CALayer
    let verseNumLabel: CATextLayer
    var progressLink: CADisplayLink?
    // Precomputed for positionVersePopup
    let sliderRange: CGFloat
    let sliderOrigin: CGFloat
    // Transient State Variables
    var scrubSliderDuration: CMTime
    var scrubSliderDrag: Bool
    var verseNum: Int = 1
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
        scrub.isContinuous = true
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
        
        // Precompute Values for positionVersePopup()
        self.sliderRange = scrub.frame.size.width - (scrub.currentThumbImage?.size.width)!
        self.sliderOrigin = scrub.frame.origin.x + ((scrub.currentThumbImage?.size.width)! / 2.0)
        
        let verse = CALayer()
        verse.frame = CGRect(x: screenWidth * 0.05, y: 195, width: 32, height: 32)
        verse.backgroundColor = UIColor.white.cgColor
        verse.contentsScale = UIScreen.main.scale
        verse.borderColor = UIColor.lightGray.cgColor
        verse.borderWidth = 1.0
        verse.cornerRadius = verse.frame.width / 2
        verse.masksToBounds = false
        verse.opacity = 0 // Will be set to 1 if data is available
        self.view.layer.addSublayer(verse)
        self.verseLabel = verse
        
        let verse2 = CATextLayer()
        verse2.frame = CGRect(x: 0, y: 8, width: 32, height: 16)
        verse2.string = "1"
        verse2.font = "HelveticaNeue" as CFString
        verse2.fontSize = 12
        verse2.foregroundColor = UIColor.black.cgColor
        verse2.isWrapped = false
        verse2.alignmentMode = kCAAlignmentCenter
        verse2.contentsGravity = kCAGravityCenter // Why doesn't contentsGravity work
        verse.addSublayer(verse2)
        self.verseNumLabel = verse2

        // UI control shadows
        playBtn.layer.shadowOpacity = 0.5
        playBtn.layer.shadowOffset = CGSize(width: 2.0, height: 1.0)
        pauseBtn.layer.shadowOpacity = 0.5
        pauseBtn.layer.shadowOffset = CGSize(width: 2.0, height: 1.0)
        stopBtn.layer.shadowOpacity = 0.5
        stopBtn.layer.shadowOffset = CGSize(width: 2.0, height: 1.0)
        verse.shadowOpacity = 0.5
        verse.shadowOffset = CGSize(width: 1.0, height: 0.5)
        scrub.layer.shadowOpacity = 0.5
        scrub.layer.shadowOffset = CGSize(width: 2.0, height: 1.0)
    }
    
    deinit {
        print("***** Deinit AudioBibleView *****")
    }
    
    @objc func play() {
        self.audioBible.play()
        if (self.isAudioViewActive) {
            self.playButton.removeFromSuperview()
            self.view.addSubview(self.pauseButton)
        }
    }
    
    @objc func pause() {
        self.audioBible.pause()
        if (self.isAudioViewActive) {
            self.pauseButton.removeFromSuperview()
            self.view.addSubview(self.playButton)
        }
    }
    
    @objc func stop() {
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
        self.scrubSlider.addTarget(self, action: #selector(touchUpInside), for: .touchUpOutside)
        self.initNotifications()
    }
    
    func stopPlay() {
        self.isAudioViewActive = false
        self.playButton.removeFromSuperview()
        self.pauseButton.removeFromSuperview()
        self.stopButton.removeFromSuperview()
        self.scrubSlider.removeFromSuperview()
        self.verseLabel.removeFromSuperlayer()
        self.progressLink?.invalidate()
        self.removeNotifications()
    }
    
    /**
    * Scrub Slider Animation
    */
    @objc func updateProgress() {
        if self.scrubSliderDrag { return }
        //print("Update progress \(CFAbsoluteTimeGetCurrent())")
        
        if let item = self.audioBible.getPlayer()?.currentItem {
            if CMTIME_IS_NUMERIC(item.duration) {
                if item.duration != self.scrubSliderDuration {
                    self.scrubSliderDuration = item.duration
                    let duration = CMTimeGetSeconds(item.duration)
                    self.scrubSlider.maximumValue = Float(duration)
                }
            }
            let current = CMTimeGetSeconds(item.currentTime())
            self.scrubSlider.setValue(Float(current), animated: true)
            
            if let verse = self.audioBible.getCurrentReference().audioChapter {
                self.verseNum = verse.findVerseByPosition(priorVerse: self.verseNum,
                                                          seconds: Double(self.scrubSlider.value))
                self.verseNumLabel.string = String(self.verseNum)
                self.verseLabel.opacity = 1
                self.verseLabel.position = positionVersePopup()
            } else {
                self.verseLabel.opacity = 0
            }
        }
        //print("Finished progress \(CFAbsoluteTimeGetCurrent())")
    }
    private func positionVersePopup() -> CGPoint {
        let slider = self.scrubSlider
        let sliderPct: Float = (slider.value - slider.minimumValue) / (slider.maximumValue - slider.minimumValue)
        let sliderValueToPixels: CGFloat = (CGFloat(sliderPct) * self.sliderRange) + self.sliderOrigin
        return CGPoint(x: sliderValueToPixels, y: 210)
    }
    
    /**
    * Scrub Slider Event Handler
    * BUG: When the slider is dragged and released it sometimes momentarily jumps back to its starting point.
    * I have verified that this is not because updateProgress was unfinished.  It seems like it must be a
    * saved screen update.  I need to learn how to discard such when the
    */
    @objc func scrubSliderChanged(sender: UISlider) {
        //print("scrub slider changed to \(sender.value)")
        if let verse = self.audioBible.getCurrentReference().audioChapter {
            self.verseNum = verse.findVerseByPosition(priorVerse: self.verseNum, seconds: Double(sender.value))
            self.verseNumLabel.string = String(self.verseNum)
            self.verseLabel.position = positionVersePopup()
        }
    }
    @objc func touchDown() {
        self.scrubSliderDrag = true
        //print("**** touchDown **** \(CFAbsoluteTimeGetCurrent())")
    }
    @objc func touchUpInside(sender: UISlider) {
        self.scrubSliderDrag = false
        //print("**** touchUpInside **** \(CFAbsoluteTimeGetCurrent())")
        
        if let play = self.audioBible.getPlayer() {
            if (sender.value < sender.maximumValue) {
                var current: CMTime
                if let verse = self.audioBible.getCurrentReference().audioChapter {
                    current = verse.findPositionOfVerse(verse: self.verseNum)
                } else {
                    current = CMTime(seconds: Double(sender.value), preferredTimescale: CMTimeScale(1.0))
                }
                play.seek(to: current)
            } else {
                self.audioBible.advanceToNextItem()
            }
        }
    }
    
    private func initNotifications() {
        let notify = NotificationCenter.default
        notify.addObserver(self, selector: #selector(applicationWillEnterForeground(note:)),
                           name: .UIApplicationWillEnterForeground, object: nil)
    }
    private func removeNotifications() {
        let notify = NotificationCenter.default
        notify.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc func applicationWillEnterForeground(note: Notification) {
        print("\n****** APP WILL ENTER FOREGROUND IN VIEW \(Date().timeIntervalSince1970)")
        if let play = self.audioBible.getPlayer() {
            if (play.rate == 0.0) {
                self.pauseButton.removeFromSuperview()
                self.view.addSubview(self.playButton)
            } else {
                self.playButton.removeFromSuperview()
                self.view.addSubview(self.pauseButton)
            }
        }
    }
}
