//
//  AudioBibleView.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/7/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import AVFoundation
import UIKit
import WebKit

class AudioBibleView {
    
    // This needs to be removed
    private static var instance: AudioBibleView?
    // This needs to be fixed in order to enable text moving with verse.
    static var webview: WKWebView? {
        get {
            if let singleton = instance {
                return singleton.view as? WKWebView
            } else {
                return nil
            }
        }
    }
    
    private unowned let view: UIView
    private unowned let audioBible: AudioBible
    private let audioPanel: UIView
    private let playUpImg: UIImage!
    private let playDnImg: UIImage!
    private let pauseUpImg: UIImage!
    private let pauseDnImg: UIImage!
    private let playButton: UIButton
    private let scrubSlider: UISlider
    private let verseLabel: CALayer
    private let verseLabelYPos: CGFloat
    private let verseNumLabel: CATextLayer
    private var progressLink: CADisplayLink?
    // Constraints
    private let panelLeft: NSLayoutConstraint
    private let panelRight: NSLayoutConstraint
    private let panelHeight: NSLayoutConstraint
    private let panelBottom: NSLayoutConstraint
    // Precomputed for positionVersePopup
    private let thumbWidth: CGFloat
    // Transient State Variables
    private var scrubSliderDuration: CMTime
    private var scrubSliderDrag: Bool
    private var scrubSuspendedPlay: Bool
    private var verseNum: Int = 0
    private var isAudioViewActive: Bool = false
    
    init(view: UIView, audioBible: AudioBible) {
        self.view = view
        self.audioBible = audioBible
        self.scrubSliderDuration = CMTime.zero
        self.scrubSliderDrag = false
        self.scrubSuspendedPlay = false

        let panel = UIView()
        panel.layer.cornerRadius = 20
        panel.layer.masksToBounds = true
        self.audioPanel = panel
        
        let screenSize = UIScreen.main.bounds
        let panelInsetX = screenSize.width * 0.03
        let panelInsetY = screenSize.width * 0.01
        self.audioPanel.translatesAutoresizingMaskIntoConstraints = false
        self.panelLeft = self.audioPanel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,
                                                                  constant: panelInsetX)
        self.panelRight = self.audioPanel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,
                                                                    constant: -panelInsetX)
        self.panelHeight = self.audioPanel.heightAnchor.constraint(equalToConstant: 115.0)
        self.panelBottom = self.audioPanel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,
                                                                   constant: -panelInsetY)
        if !UIAccessibility.isReduceTransparencyEnabled {
            self.audioPanel.backgroundColor = .clear
            
            let blur = UIBlurEffect(style: .light)
            let blurView = UIVisualEffectView(effect: blur)
            
            let vibrancy = UIVibrancyEffect(blurEffect: blur)
            let vibrancyView = UIVisualEffectView(effect: vibrancy)
            vibrancyView.translatesAutoresizingMaskIntoConstraints = false
            
            blurView.contentView.addSubview(vibrancyView)
            
            self.audioPanel.addSubview(blurView)
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.topAnchor.constraint(equalTo: self.audioPanel.topAnchor).isActive = true
            blurView.leadingAnchor.constraint(equalTo: self.audioPanel.leadingAnchor).isActive = true
            blurView.trailingAnchor.constraint(equalTo: self.audioPanel.trailingAnchor).isActive = true
            blurView.bottomAnchor.constraint(equalTo: self.audioPanel.bottomAnchor).isActive = true
        } else {
            self.audioPanel.backgroundColor = .white
        }
        
        self.playButton = UIButton(type: .custom)
        self.playUpImg = UIImage(named: "PlayUPButton44.png")
        self.playButton.setImage(self.playUpImg, for: UIControl.State.normal)
        self.playDnImg = UIImage(named: "PlayDNButton44.png")
        self.playButton.setImage(self.playDnImg, for: UIControl.State.highlighted)
        self.playButton.isEnabled = false
        self.audioPanel.addSubview(self.playButton)
        
        self.pauseUpImg = UIImage(named: "PauseUPButton44.png")
        self.pauseDnImg = UIImage(named: "PauseDNButton44.png")
        
        let scrub = UISlider()
        scrub.isContinuous = true
        let thumbUpImg = UIImage(named: "ThumbUP30.png")
        scrub.setThumbImage(thumbUpImg, for: UIControl.State.normal)
        let thumbDnImg = UIImage(named: "ThumbDN30.png")
        scrub.setThumbImage(thumbDnImg, for: UIControl.State.highlighted)
        
        scrub.setValue(0.0, animated: false)
        self.audioPanel.addSubview(scrub)
        self.scrubSlider = scrub
        
        self.scrubSlider.translatesAutoresizingMaskIntoConstraints = false
        self.scrubSlider.topAnchor.constraint(equalTo: self.audioPanel.topAnchor, constant: 40.0).isActive = true
        self.scrubSlider.leadingAnchor.constraint(equalTo: self.audioPanel.leadingAnchor,
                                                  constant: 20.0).isActive = true
        self.scrubSlider.trailingAnchor.constraint(equalTo: self.audioPanel.trailingAnchor,
                                                   constant: -20.0).isActive = true
        
        self.playButton.translatesAutoresizingMaskIntoConstraints = false
        self.playButton.topAnchor.constraint(equalTo: self.scrubSlider.bottomAnchor,
                                             constant: 0.0).isActive = true
        self.playButton.centerXAnchor.constraint(equalTo: self.audioPanel.centerXAnchor).isActive = true
        self.playButton.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
        self.playButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        
        // Precompute Values for positionVersePopup()
        self.thumbWidth = (scrub.currentThumbImage?.size.width)!
        
        self.verseLabelYPos = 20
        let panelWidth = self.audioPanel.bounds.width
        let verse = CALayer()
        verse.frame = CGRect(x: panelWidth * 0.05, y: self.verseLabelYPos, width: 32, height: 32)
        verse.backgroundColor = UIColor.white.cgColor
        verse.contentsScale = UIScreen.main.scale
        verse.borderColor = UIColor.lightGray.cgColor
        verse.borderWidth = 1.0
        verse.cornerRadius = verse.frame.width / 2
        verse.masksToBounds = false
        verse.opacity = 0 // Will be set to 1 if data is available
        self.audioPanel.layer.addSublayer(verse)
        self.verseLabel = verse
        
        let verse2 = CATextLayer()
        verse2.frame = CGRect(x: 0, y: 8, width: 32, height: 16)
        verse2.string = "1"
        verse2.font = "HelveticaNeue" as CFString
        verse2.fontSize = 12
        verse2.foregroundColor = UIColor.black.cgColor
        verse2.isWrapped = false
        verse2.alignmentMode = CATextLayerAlignmentMode.center
        verse2.contentsGravity = CALayerContentsGravity.center // Why doesn't contentsGravity work
        self.verseLabel.addSublayer(verse2)
        self.verseNumLabel = verse2
/*
        // PositionLabel is for Debug only
        let position = CATextLayer()
        position.frame = CGRect(x: screenWidth * 0.05, y: 180, width: 64, height: 32)
        position.string = "0"
        position.fontSize = 12
        position.foregroundColor = UIColor.black.cgColor
        self.view.layer.addSublayer(position)
        self.positionLabel = position
*/
        // UI control shadows

        self.playButton.layer.shadowOpacity = 0.5
        self.playButton.layer.shadowOffset = CGSize(width: 2.0, height: 1.0)
        verse.shadowOpacity = 0.5
        verse.shadowOffset = CGSize(width: 1.0, height: 0.5)
        scrub.layer.shadowOpacity = 0.5
        scrub.layer.shadowOffset = CGSize(width: 2.0, height: 1.0)
 
        self.initNotifications()
        print("***** Init AudioBibleView *****")
    }
    
    deinit {
        print("***** Deinit AudioBibleView *****")
    }
    
    func audioBibleActive() -> Bool {
        return self.isAudioViewActive
    }
    
    func audioReadyToPlay(enabled: Bool) {
        self.playButton.isEnabled = enabled
    }
    
    @objc func playPause() {
        if self.audioBible.isPlaying() {
            self.pause()
        } else {
            self.play()
        }
    }
    
    func play() {
        self.audioBible.play()
        if (self.isAudioViewActive) {
            self.setPlayButtonPlay(play: false)
        }
    }
    
    func pause() {
        self.audioBible.pause()
        if (self.isAudioViewActive) {
            self.setPlayButtonPlay(play: true)
        }
    }
    
    @objc private func stop() {
        self.audioBible.stop()
        self.dismissPlayer()
    }
    
    func presentPlayer() {
        self.isAudioViewActive = true
        self.audioPanel.center.y = self.view.bounds.height + self.audioPanel.bounds.height / 2.0
        let homeBarSafe = self.view.bounds.height * 0.01
        self.view.addSubview(self.audioPanel)
        self.panelLeft.isActive = true
        self.panelRight.isActive = true
        self.panelHeight.isActive = true
        self.panelBottom.isActive = true
        UIView.animate(withDuration: 1.0, delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: { self.audioPanel.center.y -= self.audioPanel.bounds.height + homeBarSafe },
                       completion: nil
        )
        if self.audioBible.isPlaying() {
            self.setPlayButtonPlay(play: false)
        } else {
            self.setPlayButtonPlay(play: true)
            self.audioReadyToPlay(enabled: false)
        }
        self.progressLink = CADisplayLink(target: self, selector: #selector(updateProgress))
        self.progressLink!.add(to: .current, forMode: RunLoop.Mode.default)
        self.progressLink!.preferredFramesPerSecond = 15
        
        self.playButton.addTarget(self, action: #selector(self.playPause), for: .touchUpInside)
        self.scrubSlider.addTarget(self, action: #selector(scrubSliderChanged), for: .valueChanged)
        self.scrubSlider.addTarget(self, action: #selector(touchDown), for: .touchDown)
        self.scrubSlider.addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
        self.scrubSlider.addTarget(self, action: #selector(touchUpInside), for: .touchUpOutside)
        
        UIApplication.shared.isIdleTimerDisabled = true
    }

    func dismissPlayer() {
        self.isAudioViewActive = false
        UIView.animate(withDuration: 1.0, delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: { self.audioPanel.center.y += self.audioPanel.bounds.height * 1.2 },
                       completion: { _ in
                        self.panelLeft.isActive = false
                        self.panelRight.isActive = false
                        self.panelHeight.isActive = false
                        self.panelBottom.isActive = false
                        self.audioPanel.removeFromSuperview() }
        )
        self.progressLink?.invalidate()
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    /**
    * Scrub Slider Animation
    */
    @objc private func updateProgress() {
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
            
            self.labelVerseNum(updateControlCenter: true, position: current)
        }
        //print("Finished progress \(CFAbsoluteTimeGetCurrent())")
    }
    
    private func labelVerseNum(updateControlCenter: Bool, position: Double) {
        if let reference = self.audioBible.getCurrentReference() {
            if let verse = reference.audioChapter {
                if (self.scrubSlider.value == 0.0) {
                    self.verseNum = 0
                }
                let newVerseNum = verse.findVerseByPosition(priorVerse: self.verseNum, seconds: Double(self.scrubSlider.value))
                if newVerseNum != self.verseNum {
                    self.verseNumLabel.string = String(newVerseNum)
                    if updateControlCenter {
                        AudioControlCenter.shared.updateNowPlaying(reference: reference,
                                                                   verse: newVerseNum, position: position)
                    }
                    self.verseNum = newVerseNum
                }
                self.verseLabel.opacity = 1
                self.verseLabel.position = positionVersePopup()
            } else {
                self.verseLabel.opacity = 0
            }
        } else {
            self.verseLabel.opacity = 0
        }
    }
    
    private func positionVersePopup() -> CGPoint {
        let slider = self.scrubSlider
        let sliderPct: Float = (slider.value - slider.minimumValue) / (slider.maximumValue - slider.minimumValue)
        
        let sliderRange = slider.frame.size.width - self.thumbWidth
        let sliderOrigin = slider.frame.origin.x + (self.thumbWidth / 2.0)
        let sliderValueToPixels: CGFloat = (CGFloat(sliderPct) * sliderRange) + sliderOrigin
        return CGPoint(x: sliderValueToPixels, y: self.verseLabelYPos)
    }
    
    /**
    * Scrub Slider Event Handler
    */
    @objc private func scrubSliderChanged(sender: UISlider) {
        self.labelVerseNum(updateControlCenter: false, position: 0.0)
    }
    @objc private func touchDown() {
        self.scrubSliderDrag = true
        if self.audioBible.isPlaying() {
            self.audioBible.getPlayer()?.pause()
            self.scrubSuspendedPlay = true
        }
        //print("**** touchDown **** \(CFAbsoluteTimeGetCurrent())")
    }
    @objc private func touchUpInside(sender: UISlider) {
        //print("**** touchUpInside **** \(CFAbsoluteTimeGetCurrent())")
        
        if let play = self.audioBible.getPlayer() {
            if sender.value < sender.maximumValue || !self.scrubSuspendedPlay {
                var current: CMTime
                if let verse = self.audioBible.getCurrentReference()?.audioChapter {
                    current = verse.findPositionOfVerse(verse: self.verseNum)
                } else {
                    current = CMTime(seconds: Double(sender.value), preferredTimescale: CMTimeScale(1000))
                }
                play.seek(to: current)
                self.labelVerseNum(updateControlCenter: true, position: current.seconds)
            } else {
                self.audioBible.nextChapter()
            }
            self.scrubSliderDrag = false
            if self.scrubSuspendedPlay {
                play.play()
                self.scrubSuspendedPlay = false
            }
        }
    }

    private func initNotifications() {
        let notify = NotificationCenter.default
        notify.addObserver(self, selector: #selector(applicationWillEnterForeground(note:)),
                           name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    @objc private func applicationWillEnterForeground(note: Notification) {
        print("\n****** APP WILL ENTER FOREGROUND IN VIEW \(Date().timeIntervalSince1970)")
        if self.audioBible.isPlaying() {
            self.presentPlayer()
        } else {
            self.setPlayButtonPlay(play: true)
        }
    }
    
    private func setPlayButtonPlay(play: Bool) {
        if play {
            self.playButton.setImage(playUpImg, for: UIControl.State.normal)
            self.playButton.setImage(playDnImg, for: UIControl.State.highlighted)
        } else {
            self.playButton.setImage(pauseUpImg, for: UIControl.State.normal)
            self.playButton.setImage(pauseDnImg, for: UIControl.State.highlighted)
        }
    }
}
