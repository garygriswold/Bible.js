package com.shortsands.audioplayer;

import android.app.Service;
import android.content.Intent;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.IBinder;
import android.os.PowerManager;
import android.util.Log;
import java.io.IOException;

/**
 * Created by garygriswold on 8/30/17.
 */

public class AudioBible implements MediaPlayer.OnErrorListener, MediaPlayer.OnCompletionListener,
        MediaPlayer.OnSeekCompleteListener {

    private static final String TAG = "AudioBible";

    private final AudioBibleController controller;
    private final TOCAudioBible tocBible;
    // Transient Variables
    private Reference currReference;
    private Reference nextReference;
    private MediaPlayer mediaPlayer;
    private MediaPlayer nextPlayer;

    public AudioBible(AudioBibleController controller, TOCAudioBible tocBible, Reference reference) {
        super();
        this.controller = controller;
        this.tocBible = tocBible;
        this.currReference = reference;
        this.nextReference = null;
        this.mediaPlayer = null;
        this.nextPlayer = null;
        MediaPlayState.retrieve(this.controller.activity, reference.damId, reference.getS3Key());
    }

    Reference getCurrReference() { return(this.currReference); }

    void beginStreaming() {
        this.initAudio(this.currReference.url.toString());
    }

    private void initAudio(String url) {
        if (url != null) {
            this.mediaPlayer = this.initPlayer(url);
            long seekTime = MediaPlayState.currentState.position;
            if (seekTime > 100L) {
                this.mediaPlayer.setOnSeekCompleteListener(this);
                this.mediaPlayer.seekTo((int)seekTime);
            } else {
                this.onSeekComplete(this.mediaPlayer);
            }
        } else {
            Log.e(TAG, "URL is null");
        }
    }

    @Override
    public void onSeekComplete(MediaPlayer player) {
        this.mediaPlayer.setOnSeekCompleteListener(null);
        this.mediaPlayer.start();
        this.controller.playHasStarted(this.mediaPlayer);
        this.advanceToItem(this.currReference);
    }

    private MediaPlayer initPlayer(String url) {
        MediaPlayer player = new MediaPlayer();
        player.setLooping(false);
        player.setAudioStreamType(AudioManager.STREAM_VOICE_CALL); // Replace with AudioAttributes in SDK 21
        try {
            player.setDataSource(url);
            player.prepare();
            player.setOnCompletionListener(this);
            player.setWakeMode(this.controller.activity, PowerManager.PARTIAL_WAKE_LOCK);
            return player;
        } catch(IOException ioe) {
            Log.e(TAG, "Error in AudioBible.initPlayer " + ioe.toString());
            return null;
        }
    }

    void play() {
        this.mediaPlayer.start();
    }

    void pause() {
        this.mediaPlayer.pause();
    }

    void stop() {
        this.controller.playHasStopped();
        this.updateMediaPlayStateTime();
        //this.sendAudioAnalytics();
        if (this.mediaPlayer != null) {
            this.mediaPlayer.reset();
            this.mediaPlayer.release();
            this.mediaPlayer = null;
        }
        if (this.nextPlayer != null) {
            this.nextPlayer.reset();
            this.nextPlayer.release();
            this.nextPlayer = null;
        }
    }

    @Override
    public void onCompletion(MediaPlayer player) {
        this.mediaPlayer = this.nextPlayer;
        this.controller.playHasStarted(this.mediaPlayer);
        //player.release(); // Is this needed?
        this.advanceToItem(this.nextReference);
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

    private void advanceToItem(Reference reference) {
        if (reference != null) {
            this.currReference = reference;
            this.nextReference = this.tocBible.nextChapter(this.currReference);
            this.nextPlayer = this.initPlayer(this.nextReference.url.toString());
            this.mediaPlayer.setNextMediaPlayer(this.nextPlayer);
            this.readVerseMetaData(this.currReference);
        } else {
        //    self.sendAudioAnalytics()
            MediaPlayState.clear(this.controller.activity);
            this.stop();
        }
    }

    private void updateMediaPlayStateTime() {
        TOCAudioChapter chapter = this.currReference.audioChapter;
        double position = this.mediaPlayer.getCurrentPosition() / 1000.0;
        if (chapter != null) {
            position = chapter.findVerseByPosition(position) * 1000.0;
        } else {
            position = position - 3.0;
            position = (position >= 0.0) ? position * 1000.0 : 0.0;
        }
        MediaPlayState.update(this.controller.activity, this.currReference.getS3Key(), (int)position);
    }

    private void readVerseMetaData(Reference reference) {
        ReadVerseMetaDataHandler handler = new ReadVerseMetaDataHandler(reference);
        MetaDataReader reader = new MetaDataReader(this.controller.activity);
        reader.readVerseAudio(reference.damId, reference.sequence, reference.book, reference.chapter, handler);
    }

    class ReadVerseMetaDataHandler implements CompletionHandler {
        private Reference reference;
        ReadVerseMetaDataHandler(Reference ref) {
            this.reference = ref;
        }
        public void completed(Object result, Object attachment) {
            if (result instanceof TOCAudioChapter) {
                TOCAudioChapter chapter = (TOCAudioChapter)result;
                reference.audioChapter = chapter;
                //Log.d(TAG, "************" + chapter.toString());
            } else {
                this.failed(new Exception("Could not cast to TOCAudioChapter"), attachment);
            }
        }
        public void failed(Throwable exception, Object attachment) {
            Log.e(TAG, "Exception in ReadVerseMetaDataHandler " + exception.toString());
        }
    }

    void sendAudioAnalytics() {
        //print("\n*********** INSIDE SAVE ANALYTICS *************")
        //let currTime = (self.player != nil) ? self.player!.currentTime() : kCMTimeZero
        //self.audioAnalytics.playEnded(item: self.currReference.toString(), position: currTime)
    }
}
