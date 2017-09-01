package com.shortsands.audioplayer;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
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

import java.io.IOException;
import java.net.URL;
import java.util.Date;
/**
 * Created by garygriswold on 8/30/17.
 */

public class AudioBible implements MediaPlayer.OnPreparedListener, MediaPlayer.OnErrorListener {

    private static String TAG = "AudioBible";

    private AudioBibleController controller;
    private MediaPlayer mediaPlayer = null;

    public AudioBible(AudioBibleController controller, TOCAudioBible tocBible, Reference reference) {
        this.controller = controller;
    }

    public void beginStreaming() {
        String url = "https://s3-us-west-2.amazonaws.com/audio-us-west-2-shortsands/upload_emma_test.mp3";
        this.mediaPlayer = new MediaPlayer();
        this.mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC); // or STREAM_VOICE_CALL

        try {
            this.mediaPlayer.setDataSource(url);
            this.mediaPlayer.setOnPreparedListener(this);
            //this.mediaPlayer.setWakeMode(this.controller.context, PowerManager.PARTIAL_WAKE_LOCK);
            this.mediaPlayer.prepareAsync(); // prepare async to not block main thread
        } catch(Exception err) {
            Log.d(TAG, "Error in AudioBible.beginStreaming " + err.toString());
        }
    }

    public void beginDownload() {

    }
/*
    public void beginLocal() {
        Uri myUri = new Uri(""); // initialize Uri here
        MediaPlayer mediaPlayer = new MediaPlayer();
        mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
        try {
            mediaPlayer.setDataSource(getApplicationContext(), myUri);
            mediaPlayer.prepare();
            mediaPlayer.start();
        } catch(IOException err) {
            Log.d(TAG, "Error in beginLocal " + err.toString());
        }
    }
*/
    public void onPrepared(MediaPlayer player) {
        player.start();
    }

    public void initAudio(URL url) {

    }

    private double backupSeek(MediaPlayState state) { // is it double, float or int

        return 0.0;
    }

    public void play() {

    }

    public void pause() {

    }

    public void stop() {
        if (this.mediaPlayer != null) {
            this.mediaPlayer.release();
            this.mediaPlayer = null;
        }
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
    private void initNotifications() {

    }

    private void removeNotifications() {

    }

    private void playerItemDidPlayToEndTime() { // Notification in ios

    }

    private void playerItemFailedToPlayToEndTime() { // notification in ios

    }

    private void playerItemPlaybackStalled() { // notification in ios

    }

    private void playerItemNewErrorLogEntry() { // notification in ios

    }

    private void applicationWillResignActive() { // notification in ios

    }

    public void advanceToNextItem() {

    }

    public void updateMediaPlayStateTime() {

    }

    private void readVerseMetaData(Reference reference) {

    }

    private void addNextChapter(Reference reference) {

    }

    public void sendAudioAnalytics() {

    }
}
