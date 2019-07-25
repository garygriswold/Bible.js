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
    
    private static var instance: AudioSession?
    static func shared(audioBible: AudioBible) -> AudioSession {
        if (AudioSession.instance == nil) {
            AudioSession.instance = AudioSession(audioBible: audioBible)
        }
        return AudioSession.instance!
    }
    
    private unowned let audioBible: AudioBible
    private unowned var _audioBibleView: AudioBibleView?
    
    init(audioBible: AudioBible) {
        self.audioBible = audioBible
        super.init()
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSession.Category.playback,
                                    mode: AVAudioSession.Mode.spokenAudio,
                                    options: [])
            try session.setActive(true)
        } catch let err {
            print("ERROR: Could not initialize AVAudioSession \(err)")
        }
        
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(audioSessionInterruption(note:)),
                           name: AVAudioSession.interruptionNotification,
                           object: session)
        center.addObserver(self,
                           selector: #selector(audioSessionRouteChange(note:)),
                           name: AVAudioSession.routeChangeNotification,
                           object: session)
        center.addObserver(self,
                           selector: #selector(audioSessionSilenceSecondaryAudioHint(note:)),
                           name: AVAudioSession.silenceSecondaryAudioHintNotification,
                           object: session)
        center.addObserver(self,
                           selector: #selector(audioSessionMediaServicesWereLost(note:)),
                           name: AVAudioSession.mediaServicesWereLostNotification,
                           object: session)
        center.addObserver(self,
                           selector: #selector(audioSessionMediaServicesWereReset(note:)),
                           name: AVAudioSession.mediaServicesWereResetNotification,
                           object: session)
    }
    
    deinit {
        print("***** Deinit AudioSession *****")
    }
    
    var audioBibleView: AudioBibleView? {
        get {
            return self._audioBibleView
        }
        set {
            self._audioBibleView = newValue
        }
    }
    
    @objc func audioSessionInterruption(note: NSNotification) {
        print("\n====== Audio Session Interruption")
        if let value = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt {
            if let interruption =  AVAudioSession.InterruptionType(rawValue: value) {
                switch interruption {
                case .began:
                    print("\n====== Interruption Began")
                    self.pausePlayer()
                case .ended:
                    print("\n====== Interruption Ended")
                    if let option = note.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt {
                        if AVAudioSession.InterruptionOptions(rawValue: option) == .shouldResume {
                            self.playPlayer()
                        }
                    }
                }
            }
        }
    }
    
    @objc func audioSessionRouteChange(note: Notification) {
        print("\n====== Audio Session Route Change ======")
        if let userInfo = note.userInfo {
            if let value = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt {
                print("====== Route Change VALUE \(value))")
                if let reason = AVAudioSession.RouteChangeReason(rawValue: value) {
                    switch reason {
                    case .unknown:
                        print("====== Unknown ======")
                    case .newDeviceAvailable:
                        print("====== New Device Available ======")
                    case .oldDeviceUnavailable: // 2
                        print("====== Old Device Unavailable ======")
                        self.pausePlayer()
                    case .categoryChange:
                        print("====== Category Change ======")
                    case .override:
                        print("====== Override ======")
                    case .wakeFromSleep:
                        print("====== Wake From Sleep ======")
                    case .noSuitableRouteForCategory:
                        print("====== No Suitable Route For Category ======")
                    case .routeConfigurationChange:
                        print("====== Route Configuration Change ======")
                    }
                }
            }
        }
    }
    
    @objc func audioSessionSilenceSecondaryAudioHint(note: Notification) {
        print("\n====== Audio Session Silence Secondary Audio \(String(describing: note.userInfo))")
        if let userInfo = note.userInfo {
            if let value = userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey] as? UInt {
                if let type = AVAudioSession.SilenceSecondaryAudioHintType(rawValue: value) {
                    switch type {
                    case .begin:
                        self.pausePlayer()
                    case .end:
                        self.playPlayer()
                    }
                }
            }
        }
    }
    
    @objc func audioSessionMediaServicesWereLost(note: Notification) {
        print("\n====== Audio Session Services Were Lost \(String(describing: note.userInfo))")
    }
    
    @objc func audioSessionMediaServicesWereReset(note: Notification) {
        print("\n====== Audio Session Services Were Reset \(String(describing: note.userInfo))")
        // According to Apple docs, this should be handled, but its occurrance is rare.
        // I do not know how to test, so it has not been done.
    }
    
    private func playPlayer() {
        print("====== Will resume Bible audio ======")
        if self._audioBibleView != nil {
            DispatchQueue.main.async {
                self._audioBibleView!.play()
            }
        } else {
            self.audioBible.play()
        }
    }
    
    private func pausePlayer() {
        print("====== Will pause Bible audio ======")
        if self._audioBibleView != nil {
            DispatchQueue.main.async {
                self._audioBibleView!.pause()
            }
        } else {
            self.audioBible.pause()
        }
    }
}

/*
boolean = session.isOtherAudioPlaying
*/
