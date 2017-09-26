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

import Foundation
import AVFoundation

class AudioSession {
    
    let session: AVAudioSession = AVAudioSession.sharedInstance()
    let audioBibleView: AudioBibleView
    
    init(audioBibleView: AudioBibleView) {
        self.audioBibleView = audioBibleView
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
                           object: nil)
        center.addObserver(self,
                           selector: #selector(audioSessionRouteChange(note:)),
                           name: .AVAudioSessionRouteChange,
                           object: nil)
        center.addObserver(self,
                           selector: #selector(audioSessionSilenceSecondaryAudioHint(note:)),
                           name: .AVAudioSessionSilenceSecondaryAudioHint,
                           object: nil)
        center.addObserver(self,
                           selector: #selector(audioSessionMediaServicesWereLost(note:)),
                           name: .AVAudioSessionMediaServicesWereLost,
                           object: nil)
        center.addObserver(self,
                           selector: #selector(audioSessionMediaServicesWereReset(note:)),
                           name: .AVAudioSessionMediaServicesWereReset,
                           object: nil)
    }
    
    deinit {
        print("***** Deinit AudioSessionDelegate *****")
        // session does not need to be deactivated
    }
    
    @objc func audioSessionInterruption(note: NSNotification) {
        print("****** handleInterruption")
        if let value = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt {
            if let interruptionType =  AVAudioSessionInterruptionType(rawValue: value) {
                switch interruptionType {
                    case .began:
                        print("**** Began")
                        self.audioBibleView.pause()
                       do {
                            try self.session.setActive(false)
                            print("**** AVAudioSession is inactive")
                        } catch let error as NSError {
                            print(error.localizedDescription)
                        }
                    case .ended:
                        print("**** Ended")
                        if let optionValue = (note.userInfo?[AVAudioSessionInterruptionOptionKey] as? NSNumber)?.uintValue, AVAudioSessionInterruptionOptions(rawValue: optionValue) == .shouldResume {
                            print("Should resume")
                            do {
                                try self.session.setActive(true)
                                print("**** AVAudioSession is Active again")
                                self.audioBibleView.play()
                            } catch let error as NSError {
                                print(error.localizedDescription)
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
                print("** Route Change VALUE \(value))")
                if let reason = AVAudioSessionRouteChangeReason(rawValue: value) {
                    switch reason {
                        case .newDeviceAvailable:
                            print("New Device Available")
                            //self.audioBibleView.pause()
                            self.audioBibleView.audioBible.pause()
                        case .oldDeviceUnavailable:
                            print("Old Device Unavailable")
                            self.audioBibleView.pause()
                        case .routeConfigurationChange:
                            print("route configuration change")
                            //self.audioBibleView.play()
                            self.audioBibleView.audioBible.play()
                    default: ()
                    }
                }
            }
        }
    }
    @objc func audioSessionSilenceSecondaryAudioHint(note: Notification) {
        print("\n****** Audio Session Silence Secondary Audio \(String(describing: note.userInfo))")
    }
    @objc func audioSessionMediaServicesWereLost(note: Notification) {
        print("\n****** Audio Session Services Were Lost \(String(describing: note.userInfo))")
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
