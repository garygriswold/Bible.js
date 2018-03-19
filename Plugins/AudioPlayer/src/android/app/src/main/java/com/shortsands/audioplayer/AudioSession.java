package com.shortsands.audioplayer;

/**
 * Created by garygriswold on 9/27/17.
 *
 * This class is very distinct from the iOS version of AudioSession,
 * because the Android provided services are very different from iOS.
 *
 * Documentation: https://developer.android.com/guide/topics/media-apps/audio-focus.html
 *
 * When I upgrade to API 21 minimum, I should use AudioAttributes class
 * When I upgrade to API 26 minimum, I should use AudioFocusRequest class
 *
 */
import android.app.Activity;
import android.content.Context;
import android.media.AudioManager;
import android.util.Log;

class AudioSession implements AudioManager.OnAudioFocusChangeListener {

    private static final String TAG = "AudioSession";

    private static AudioSession instance = null;
    static AudioSession shared(Activity activity, AudioBibleView audioBibleView) {
        if (AudioSession.instance == null) {
            AudioSession.instance = new AudioSession(activity, audioBibleView);
        }
        return AudioSession.instance;
    }

    private final Activity activity;
    private AudioBibleView audioBibleView;
    private final AudioManager audioManager;


    private AudioSession(Activity activity, AudioBibleView audioBibleView) {
        this.activity = activity;
        this.audioBibleView = audioBibleView;
        this.audioManager = (AudioManager)this.activity.getSystemService(Context.AUDIO_SERVICE);
        this.activity.setVolumeControlStream(AudioManager.STREAM_VOICE_CALL);
    }

    public void onAudioFocusChange(int focusChange) {
        Log.d(TAG, "AUDIO FOCUS CHANGED " + focusChange);
        switch (focusChange) {
            case AudioManager.AUDIOFOCUS_GAIN: // Also AUDIOFOCUS_REQUEST_GRANTED
                Log.d(TAG, "FOCUS GAIN");
                this.audioBibleView.play();
                break;
            case AudioManager.AUDIOFOCUS_GAIN_TRANSIENT:
                Log.d(TAG, "FOCUS GAIN TRANSIENT");
                this.audioBibleView.play();
                break;
            case AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE:
                Log.d(TAG, "FOCUS GAIN TRANSIENT EXCLUSIVE");
                this.audioBibleView.play();
                break;
            case AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK:
                Log.d(TAG, "FOCUS GAIN TRANSIENT MAY DUCK");
                this.audioBibleView.play();
                break;
            case AudioManager.AUDIOFOCUS_LOSS:
                Log.d(TAG, "FOCUS LOSS");
                this.audioBibleView.pause();
                break;
            case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT:
                Log.d(TAG, "FOCUS LOSS TRANSIENT");
                this.audioBibleView.pause();
                break;
            case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK:
                Log.d(TAG, "FOCUS LOSS TRANSIENT");
                this.audioBibleView.pause();
                break;
            case AudioManager.AUDIOFOCUS_REQUEST_FAILED:
                Log.d(TAG, "FOCUS REQUEST FAILED");
                this.audioBibleView.pause();
                break;
            default:
                Log.d(TAG, "AUDIO FOCUS CHANGE UNKNOWN " + focusChange);
        }
    }

    boolean startAudioSession() {
        int result = this.audioManager.requestAudioFocus(this, AudioManager.STREAM_VOICE_CALL,
                AudioManager.AUDIOFOCUS_GAIN);
        Log.d(TAG, "Audio focus request " + result);
        return(result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED);
    }

    void stopAudioSession() {
        int result = this.audioManager.abandonAudioFocus(this);
        Log.d(TAG, "Audio focus abandon " + result);
    }
}
