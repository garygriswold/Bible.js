//
//  AudioSession.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 9/23/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//
// Documentation: https://developer.apple.com/documentation/avfoundation/avaudiosession
// https://developer.apple.com/library/content/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/Introduction/Introduction.html
// http://www.densci.com/files/files/Denville/ProductDocs/AudioSessionProgrammingGuide.pdf
// http://devstreaming.apple.com/videos/wwdc/2016/507n0zrhzxdzmg20zcl/507/507_delivering_an_exceptional_audio_experience.pdf
//
// Category AVAudioSessionCategoryPlayback means that audio will play when the lock screen is on.
// to have it continue in background when the screen locks, one must also set
// UIBackgroundModes -> audio
//

import AVFoundation

class AudioSession : NSObject {
    
    private let session: AVAudioSession = AVAudioSession.sharedInstance()
    private unowned let audioBibleView: AudioBibleView
    
    init(audioBibleView: AudioBibleView) {
        self.audioBibleView = audioBibleView
        super.init()
        do {
            try self.session.setCategory(AVAudioSessionCategoryPlayback,
                                         mode: AVAudioSessionModeSpokenAudio,
                                         options: [])
            try self.session.setActive(true)
        } catch let err {
            print("Could not initialize AVAudioSession \(err)")
        }
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(audioSessionInterruption(note:)),
                           name: .AVAudioSessionInterruption,
                           object: self.session)
        center.addObserver(self,
                           selector: #selector(audioSessionRouteChange(note:)),
                           name: .AVAudioSessionRouteChange,
                           object: self.session)
        center.addObserver(self,
                           selector: #selector(audioSessionSilenceSecondaryAudioHint(note:)),
                           name: .AVAudioSessionSilenceSecondaryAudioHint,
                           object: self.session)
        center.addObserver(self,
                           selector: #selector(audioSessionMediaServicesWereReset(note:)),
                           name: .AVAudioSessionMediaServicesWereReset,
                           object: self.session)
    }
    
    deinit {
        print("***** Deinit AudioSession *****")
    }
    
    @objc func audioSessionInterruption(note: NSNotification) {
        if let value = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt {
            if let interruptionType =  AVAudioSessionInterruptionType(rawValue: value) {
                if interruptionType == .began {
                    print("\n****** Interruption Began")//, Pause in UI")
                    //self.audioBibleView.pause()
                } else if interruptionType == .ended {
                    print("\n****** Interruption Ended, Play in UI, try to resume")
                    if let optionValue = note.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt {
                        if AVAudioSessionInterruptionOptions(rawValue: optionValue) == .shouldResume {
                            print("****** Should resume")
                            self.audioBibleView.play()
                        }
                    }
                }
            }
        }
    }
    @objc func audioSessionRouteChange(note: Notification) {
        print("\n****** Audio Session Route Change")
        if let userInfo = note.userInfo {
            if let value = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt {
                print("****** Route Change VALUE \(value))")
                if let reason = AVAudioSessionRouteChangeReason(rawValue: value) {
                    if reason == .oldDeviceUnavailable {
                        print("****** Old Device Unavailable, pause in UI")
                        if Thread.isMainThread {
                            self.pausePlayer()
                        } else {
                            performSelector(onMainThread: #selector(pausePlayer), with: nil, waitUntilDone: false)
                        }
                    }
                }
            }
        }
    }
    @objc private func pausePlayer() {
        self.audioBibleView.pause()
    }
    @objc func audioSessionSilenceSecondaryAudioHint(note: Notification) {
        print("\n****** Audio Session Silence Secondary Audio \(String(describing: note.userInfo))")
    }
    @objc func audioSessionMediaServicesWereReset(note: Notification) {
        print("\n****** Audio Session Services Were Reset \(String(describing: note.userInfo))")
        // According to Apple docs, this should be handled, but its occurrance is rare.
        // I do not know how to test, so it has not been done.
    }
}

/*
boolean = session.isOtherAudioPlaying
*/
