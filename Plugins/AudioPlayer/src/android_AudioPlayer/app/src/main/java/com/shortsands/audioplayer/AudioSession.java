package com.shortsands.audioplayer;

/**
 * Created by garygriswold on 9/27/17.
 *
 * Documentation: https://developer.android.com/guide/topics/media-apps/audio-focus.html
 *
 * When I upgrade to API 21 minimum, I should use AudioAttributes class
 * When I upgrade to API 26 minimum, I should use AudioFocusRequest class
 *
 */
import android.content.Context;
import android.os.Handler;
import android.media.AudioManager;
import android.util.Log;

class AudioSession implements AudioManager.OnAudioFocusChangeListener {

    private static final String TAG = "AudioSession";

    private Context context;
    private AudioBibleView audioBibleView;
    private AudioManager audioManager;

    AudioSession(Context context, AudioBibleView audioBibleView) {
        this.context = context;
        this.audioBibleView = audioBibleView;
        this.audioManager = (AudioManager)this.context.getSystemService(Context.AUDIO_SERVICE);
    }

    public void onAudioFocusChange(int focusChange) {
        Log.d(TAG, "AUDIO FOCUS CHANGED " + focusChange);
        switch (focusChange) {
            case AudioManager.AUDIOFOCUS_GAIN: // Also AUDIOFOCUS_REQUEST_GRANTED
                Log.d(TAG, "FOCUS GAIN");
                //if (mPlaybackDelayed || mResumeOnFocusGain) {
                //    synchronized(mFocusLock) {
                //        mPlaybackDelayed = false;
                //        mResumeOnFocusGain = false;
                //    }
                //    //playbackNow();
                //}
                break;
            case AudioManager.AUDIOFOCUS_GAIN_TRANSIENT:
                Log.d(TAG, "FOCUS GAIN TRANSIENT");
                break;
            case AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE:
                Log.d(TAG, "FOCUS GAIN TRANSIENT EXCLUSIVE");
                break;
            case AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK:
                Log.d(TAG, "FOCUS GAIN TRANSIENT MAY DUCK");
                break;
            case AudioManager.AUDIOFOCUS_LOSS:
                Log.d(TAG, "FOCUS LOSS");
                //synchronized(mFocusLock) {
                //    mResumeOnFocusGain = false;
                //    mPlaybackDelayed = false;
                //}
                //pausePlayback();
                break;
            case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT:
                Log.d(TAG, "FOCUS LOSS TRANSIENT");
                //synchronized(mFocusLock) {
                //    mResumeOnFocusGain = true;
                //    mPlaybackDelayed = false;
                //}
                //pausePlayback();
                break;
            case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK:
                Log.d(TAG, "FOCUS LOSS TRANSIENT");
                // ... pausing or ducking depends on your app
                //pausePlayback();
                break;
            case AudioManager.AUDIOFOCUS_REQUEST_FAILED:
                Log.d(TAG, "FOCUS REQUEST FAILED");
                break;
            default:
                Log.d(TAG, "AUDIO FOCUS CHANGE UNKNOWN " + focusChange);
        }
    }

    void startAudioSession() {
        int result = this.audioManager.requestAudioFocus(this,
                AudioManager.STREAM_VOICE_CALL,
                AudioManager.AUDIOFOCUS_GAIN);
        Log.d(TAG, "Audio focus request " + result);
        if (result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
            // Start playback
            Log.d(TAG, "INSIDE START SESSION REQUEST GRANTED");
        }
    }

    void stopAudioSession() {
        this.audioManager.abandonAudioFocus(this);
    }
}

/*
import Foundation
import AVFoundation

class AudioSession: NSObject {

    let session: AVAudioSession = AVAudioSession.sharedInstance()
    let audioBibleView: AudioBibleView

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
        print("***** Deinit AudioSessionDelegate *****")
        // session does not need to be deactivated
    }

    @objc func audioSessionInterruption(note: NSNotification) {
        if let value = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt {
            if let interruptionType =  AVAudioSessionInterruptionType(rawValue: value) {
                if interruptionType == .began {
                    print("\n****** Interruption Began, Pause in UI")
                    self.audioBibleView.pause()
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
 */
