package com.shortsands.audioplayer;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.media.AudioAttributes;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnPreparedListener;
import android.net.Uri;
import android.os.Bundle;

import android.os.PowerManager;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.MediaController;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.VideoView;

import com.shortsands.aws.AwsS3;

import java.io.IOException;
import java.net.URL;
import java.util.Date;
/**
 * Created by garygriswold on 8/30/17.
 */

public class AudioBible implements MediaPlayer.OnErrorListener, MediaPlayer.OnCompletionListener {

    private static String TAG = "AudioBible";

    private AudioBibleController controller;
    private TOCAudioBible tocBible;
    // Transient Variables
    private Reference currReference;
    private Reference nextReference;
    public MediaPlayer mediaPlayer;
    private MediaPlayer nextPlayer;

    public AudioBible(AudioBibleController controller, TOCAudioBible tocBible, Reference reference) {
        this.controller = controller;
        this.tocBible = tocBible;
        this.currReference = reference;
        this.nextReference = null;
        this.mediaPlayer = null;
        this.nextPlayer = null;
    }

    public void beginStreaming() {
        this.initAudio(this.currReference.url.toString());
    }

    public void beginDownload() {

    }

    public void beginLocal() {

    }

    private void initAudio(String url) {
        if (url != null) {
            this.mediaPlayer = this.initPlayer(url);
            this.mediaPlayer.start();
            this.controller.playHasStarted(this.mediaPlayer);
            this.advanceToNextItem(this.currReference);
            //let seekTime = backupSeek(state: MediaPlayState.currentState)
            //if (CMTimeGetSeconds(seekTime) > 0.1) {
            //    playerItem.seek(to: seekTime)
            //}
        } else {
            Log.e(TAG, "URL is null");
        }
    }

    private MediaPlayer initPlayer(String url) {
        MediaPlayer player = new MediaPlayer();
        player.setLooping(false);
        player.setAudioStreamType(AudioManager.STREAM_VOICE_CALL); // Replace with AudioAttributes in SDK 21
        try {
            player.setDataSource(url);
            player.prepare();
            player.setOnCompletionListener(this);
            //player.setWakeMode(this.controller.context, PowerManager.PARTIAL_WAKE_LOCK);
            return player;
        } catch(IOException ioe) {
            Log.e(TAG, "Error in AudioBible.initPlayer " + ioe.toString());
            return null;
        }
    }

    private double backupSeek(MediaPlayState state) { // is it double, float or int
        //if (state.mediaUrl == self.currReference.toString()) {
        //    return state.position
        //} else {
        //    return kCMTimeZero
        //}
        return 0.0;
    }

    public void play() {
        this.mediaPlayer.start();
    }

    public void pause() {
        this.mediaPlayer.pause();
    }

    public void stop() {
        if (this.mediaPlayer != null) {
            this.mediaPlayer.release();
            this.mediaPlayer = null;
        }
        if (this.nextPlayer != null) {
            this.nextPlayer.release();
            this.nextPlayer = null;
        }
        this.controller.playHasStopped();
    }

    @Override
    public void onCompletion(MediaPlayer player) {
        this.mediaPlayer = this.nextPlayer;
        this.controller.playHasStarted(this.mediaPlayer);
        //player.release(); // Is this needed?
        this.advanceToNextItem(this.nextReference);
    }

    @Override
    public boolean onError(MediaPlayer player, int what, int extra) {
        //this.errorTime = System.currentTimeMillis();
        String message;
        switch (what) {
            case MediaPlayer.MEDIA_ERROR_IO:
                message = "MEDIA ERROR IO";
                break;
            case MediaPlayer.MEDIA_ERROR_MALFORMED:
                message = "MEDIA ERROR MALFORMED";
                break;
            case MediaPlayer.MEDIA_ERROR_NOT_VALID_FOR_PROGRESSIVE_PLAYBACK:
                message = "MEDIA ERROR NOT VALID FOR PROGRESSIVE PLAYBACK";
                break;
            case MediaPlayer.MEDIA_ERROR_SERVER_DIED:
                message = "MEDIA ERROR SERVER DIED";
                break;
            case MediaPlayer.MEDIA_ERROR_TIMED_OUT:
                message = "MEDIA ERROR TIMED OUT";
                break;
            case MediaPlayer.MEDIA_ERROR_UNKNOWN:
                message = "MEDIA ERROR UNKNOWN";
                break;
            case MediaPlayer.MEDIA_ERROR_UNSUPPORTED:
                message = "MEDIA ERROR UNSUPPORTED";
                break;
            default:
                message = "Unknown Error " + what;
        }
        Log.e(TAG, "onError " + message + " " + extra);

        mediaPlayer.reset();
        //this.onErrorRecovery = true;
        //this.progressBar.setVisibility(View.VISIBLE);
        //Uri videoUri = Uri.parse(this.videoUrl);
        //this.videoView.setVideoURI(videoUri);

        return true;
    }

    private void applicationWillResignActive() { // notification in ios
        //print("\n******* APPLICATION WILL RESIGN ACTIVE *** in AVPlayerViewController")
        //self.sendAudioAnalytics()
        //self.updateMediaPlayStateTime()
        //self.stop()
    }

    public void advanceToNextItem(Reference reference) {
        if (reference != null) {
            this.currReference = reference;
            this.nextReference = this.tocBible.nextChapter(this.currReference);
            this.nextPlayer = this.initPlayer(this.nextReference.url.toString());
            this.mediaPlayer.setNextMediaPlayer(this.nextPlayer);
            //this.readVerseMetaData(this.currReference);
        } else {
        //    self.sendAudioAnalytics()
        //    MediaPlayState.clear()
            this.stop();
        }
    }

    public void updateMediaPlayStateTime() {
        //var result: CMTime = kCMTimeZero
        //if let currentTime = self.player?.currentTime() {
        //    if let time: CMTime = self.audioChapter?.findVerseByPosition(time: currentTime) {
        //        result = time
        //    }
        //}
        //MediaPlayState.update(url: self.currReference.toString(), time: result)
    }

    private void readVerseMetaData(Reference reference) {
        //let reader = MetaDataReader()
        //reader.readVerseAudio(damid: reference.damId, sequence: reference.sequence, bookId: reference.book, chapter: reference.chapter, readComplete: {
        //    audioChapter in
        //    self.audioChapter = audioChapter
        //    //print("PARSED DATA \(self.audioChapter?.toString())")
        //})
    }

    public void sendAudioAnalytics() {
        //print("\n*********** INSIDE SAVE ANALYTICS *************")
        //let currTime = (self.player != nil) ? self.player!.currentTime() : kCMTimeZero
        //self.audioAnalytics.playEnded(item: self.currReference.toString(), position: currTime)
    }
}
