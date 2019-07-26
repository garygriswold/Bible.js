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
            // AVAudioSession.CategoryOptions = []
            // .mixWithOthers - prevented NowPlaying from appearing
            // .duckOthers - prevented NowPlaying from appearing
            // .interruptSpokenAudioAndMixWithOthers - prevented NowPlaying from appearing
            // .defaultToSpeaker - NowPlaying appears, but was not updated with title and progress
            // .allowAirPlay - NowPlaying appears, but is not updated
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
        center.addObserver(self,
                           selector: #selector(applicationDidEnterBackground(note:)),
                           name: UIApplication.didEnterBackgroundNotification,
                           object: nil)
        center.addObserver(self,
                           selector: #selector(applicationWillEnterForeground(note:)),
                           name: UIApplication.willEnterForegroundNotification,
                           object: nil)
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
    
    @objc private func audioSessionInterruption(note: NSNotification) {
        if let value = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt {
            if let interruption =  AVAudioSession.InterruptionType(rawValue: value) {
                switch interruption {
                case .began:
                    print("\n====== Audio Interruption Began")
                    self.pausePlayer()
                case .ended:
                    print("\n====== Audio Interruption Ended")
                    if let option = note.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt {
                        if AVAudioSession.InterruptionOptions(rawValue: option) == .shouldResume {
                            self.playPlayer()
                        }
                    }
                }
            }
        }
    }
    
    @objc private func audioSessionRouteChange(note: Notification) {
        if let userInfo = note.userInfo {
            if let value = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt {
                if let reason = AVAudioSession.RouteChangeReason(rawValue: value) {
                    switch reason {
                    case .unknown:
                        print("\n====== Audio Route Change, Unknown ======")
                    case .newDeviceAvailable:
                        print("\n====== Audio Route Change, New Device Available ======")
                    case .oldDeviceUnavailable: // 2
                        print("\n====== Audio Route Change, Old Device Unavailable ======")
                        self.pausePlayer()
                    case .categoryChange: // 3
                        print("\n====== Audio Route Change, Category Change ======")
                    case .override: // 4
                        print("\n====== Audio Route Change, Override ======")
                    case .wakeFromSleep:
                        print("\n====== Audio Route Change, Wake From Sleep ======")
                    case .noSuitableRouteForCategory:
                        print("\n====== Audio Route Change, No Suitable Route For Category ======")
                    case .routeConfigurationChange: // 8
                        print("\n====== Audio Route Change, Route Configuration Change ======")
                    }
                }
            }
        }
    }
    
    @objc private func audioSessionSilenceSecondaryAudioHint(note: Notification) {
        if let userInfo = note.userInfo {
            if let value = userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey] as? UInt {
                if let type = AVAudioSession.SilenceSecondaryAudioHintType(rawValue: value) {
                    switch type {
                    case .begin:
                        print("\n====== Audio Silence Secondary Audio, Begin")
                        self.pausePlayer()
                    case .end:
                        print("\n====== Audio Silence Secondary Audio, End")
                        self.playPlayer()
                    }
                }
            }
        }
    }
    
    @objc private func audioSessionMediaServicesWereLost(note: Notification) {
        print("\n====== Audio Session Services Were Lost \(String(describing: note.userInfo))")
    }
    
    @objc private func audioSessionMediaServicesWereReset(note: Notification) {
        print("\n====== Audio Session Services Were Reset \(String(describing: note.userInfo))")
        // According to Apple docs, this should be handled, but its occurrance is rare.
        // I do not know how to test, so it has not been done.
    }
    
    /**
    * Pause audio in background if the builtInSpeaker is the only output.
    * Otherwise, allow background play to continue
    */
    @objc private func applicationDidEnterBackground(note:Notification) {
        print("\n====== APP DID ENTER BACKGROUND \(String(describing: note.object))")
        if self.audioBible.isPlaying() {
            let session = AVAudioSession.sharedInstance()
            let outputs: [AVAudioSessionPortDescription] = session.currentRoute.outputs
            print("====== Port Count \(outputs.count) Port 0: \(outputs[0].portName)")
            if outputs.count == 1 {
                if outputs[0].portType == AVAudioSession.Port.builtInSpeaker {
                    self.pausePlayer()
                }
            }
        }
    }
    
    @objc private func applicationWillEnterForeground(note:Notification) {
        print("\n====== APP WILL ENTER FOREGROUND \(String(describing: note.object))")
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

/*
 Interruption Logic
 
 Plugin headphones, or put on earbuds
    Audio Route Change, New Device Available
 
 Unplug headphones, or take off earbuds
    Audio Route Change, Old Device Unavailable
    Will pause Bible Audio
 
 Turn on car, plug in iPhone
    no interruption
    List screens ready
 
 Plug in iPhone, turn on car
    no interruption
    List screens ready
 
 Select first item to play
    Audio Route Change, Category, value = 3
 
 Apple Nav starts
    Audio Interruption began
    Will Pause Audio
 
 Apple Nav ends
    Audio Interruption ended
    Will Resume Audio
 
 Message starts reading
    Audio Interruption began
    Will Pause Audio
    (after pause) Audio Route change, Configuration Change, value = 8
 
 Message ends reading
    Audio Route change, Configuration Change, value = 8
    Audio Interruption ended
    Will Resume Audio
 
 Disconnect phone
    Audio Route change, Old device Unavailable, value = 2
    Will Pause Audio
 
 Connect phone
    Audio Route change, Category Change, value = 3
    Now Playing is ready to play
 
 Turn car off
    Audio Route change, Override, value = 4
    Audio Interruption began
    Will Pause Audio
 
 Turn car on
    Audio Interruption ended
    Will Resume Audio
    (after play starts) Audio Route change, Category Change, value = 3
 
 Apple Music starts
    Audio Interruption began
    Will Pause Audio
 
 Apple Music ends - does not exist
    User changes back to Bible
    Now Playing is ready to play
 
 Porsche Music starts
    Audio Route Change, Override, value = 4
    Audio Interruption began
    Will Pause Audio
 
 Porsche Music ends - does not exist
    User changes back to Bible
    Now Playing is ready to play
 
 Porsche Nav starts
    There is no notification
 
 Porsche Nav ends
    There is no notification
 
 Phone call starts
    Audio Interruption began
    Will pause Bible audio
    (after pause) Audio Route Change, Route Configuration Change (repeated)
 
 Phone call ends
    Audio Route Change, Route Configuration Change
    Audio Interruption ended
    Will resume Bible audio
 
 App Will Enter Foreground - this does nothing
 App Will Enter Foreground in View - this presents player if it exists

*/
