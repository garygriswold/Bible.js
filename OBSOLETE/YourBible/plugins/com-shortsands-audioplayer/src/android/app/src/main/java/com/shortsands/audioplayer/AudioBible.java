package com.shortsands.audioplayer;

import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.PowerManager;
import android.util.Log;
import com.shortsands.aws.AwsS3Cache;
import com.shortsands.aws.CompletionHandler;
import java.io.File;
import java.io.IOException;

/**
 * Created by garygriswold on 8/30/17.
 */

public class AudioBible implements MediaPlayer.OnErrorListener, MediaPlayer.OnCompletionListener,
        MediaPlayer.OnSeekCompleteListener {

    private static final String TAG = "AudioBible";

    private static AudioBible instance = null;
    static AudioBible shared(AudioBibleController controller) {
        if (AudioBible.instance == null) {
            AudioBible.instance = new AudioBible(controller);
        }
        return(AudioBible.instance);
    }

    private final AudioBibleController controller;
    private final AudioControlCenter controlCenter;
    private AudioAnalytics audioAnalytics;
    // Transient Variables
    private AudioReference currReference;
    private AudioReference nextReference;
    private MediaPlayer mediaPlayer;
    private MediaPlayer nextPlayer;

    private AudioBible(AudioBibleController controller) {
        super();
        this.controller = controller;
        this.controlCenter = AudioControlCenter.shared;
    }

    MediaPlayer getPlayer() {
        return this.mediaPlayer;
    }

    AudioReference getCurrReference() {
        return this.currReference;
    }

    boolean isPlaying() {
        return (this.mediaPlayer != null) ? this.mediaPlayer.isPlaying() : false;
    }

    void beginReadFile(AudioReference reference) {
        Log.d(TAG, "BibleReader.BEGIN Read File");
        this.currReference = reference;
        this.audioAnalytics = new AudioAnalytics(controller.activity,
            reference.tocAudioBook.testament.bible.mediaSource,
            reference.damId(),
            reference.dbpLanguageCode(),
            reference.textVersion(),
            reference.silLang());
        BeginReadFileCompletion handler = new BeginReadFileCompletion();
        this.readVerseMetaData(reference);
        AudioPlayState.retrieve(this.controller.activity, reference.damId());
        AwsS3Cache.shared().readFile(reference.getS3Bucket(),
                reference.getS3Key(),
                Integer.MAX_VALUE,
                handler);
    }

    class BeginReadFileCompletion implements CompletionHandler {
        @Override
        public void completed(Object result) {
            if (result instanceof File) {
                File file = (File) result;
                initAudio(file);
            }
        }
        @Override
        public void failed(Throwable exception) {
            Log.d(TAG, "BeginReadFile Failed " + exception.toString());
        }
    }

    private void initAudio(File url) {
        if (url != null) {
            this.mediaPlayer = this.initPlayer(url);
            if (this.mediaPlayer != null) {
                long seekTime = this.backupSeek(AudioPlayState.currentState, this.currReference);
                if (seekTime > 100L) {
                    this.mediaPlayer.setOnSeekCompleteListener(this);
                    this.mediaPlayer.seekTo((int) seekTime);
                } else {
                    this.onSeekComplete(this.mediaPlayer);
                }
            }
        } else {
            Log.e(TAG, "URL is null");
        }
    }

    private long backupSeek(AudioPlayState state, AudioReference reference) {
        if (state.mediaUrl != null && state.mediaUrl.equals(reference.toString())) {
            if (reference.audioChapter != null) {
                return state.position;
            } else {
                long duration = System.currentTimeMillis() - state.timestamp;
                long backupSec = String.valueOf(duration / 1000L).length() * 1000L;  // could multiply by a factor here
                return(state.position - backupSec);
            }
        } else {
            return 0L;
        }
    }

    @Override
    public void onSeekComplete(MediaPlayer player) {
        player.setOnSeekCompleteListener(null);
        this.play();
        player.setOnCompletionListener(this);
        this.controller.playHasStarted(player);
        this.controlCenter.nowPlaying(this);
        this.preFetchNextChapter(this.currReference);
    }

    private MediaPlayer initPlayer(File file) {
        String url = file.getAbsolutePath();
        MediaPlayer player = new MediaPlayer();
        player.setLooping(false);
        player.setAudioStreamType(AudioManager.STREAM_VOICE_CALL); // Replace with AudioAttributes in SDK 21
        try {
            player.setDataSource(url);
            player.prepare();
            player.setWakeMode(this.controller.activity, PowerManager.PARTIAL_WAKE_LOCK);
            return player;
        } catch(IOException ioe) {
            Log.e(TAG, "Error in AudioBible.initPlayer " + ioe.toString());
            return null;
        }
    }

    void play() {
        Log.d(TAG, "\n*********** PLAY *************");
        if (this.mediaPlayer != null) {
            this.mediaPlayer.start();
            long currTime = this.mediaPlayer.getCurrentPosition();
            this.audioAnalytics.playStarted(this.currReference.toString(), currTime);
        }
    }

    void pause() {
        Log.d(TAG, "\n*********** PAUSE *************");
        if (this.mediaPlayer != null) {
            this.mediaPlayer.pause();
            long currTime = this.mediaPlayer.getCurrentPosition();
            this.audioAnalytics.playEnded(this.currReference.toString(), currTime);
            this.updateMediaPlayStateTime(this.currReference);
        }
    }

    void stop() {
        if (this.mediaPlayer != null && this.mediaPlayer.isPlaying()) {
            this.pause();
        }
        this.controller.playHasStopped();
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

    /** This method is called by AudioControlCenter, which is not implemented in the android version */
    void nextChapter() {
        if (this.nextReference != null) {
            this.currReference = this.nextReference;
            this.addNextChapter(this.currReference);
            this.preFetchNextChapter(this.currReference);
        } else {
            this.stop();
            AudioPlayState.clear(this.controller.activity); // Must be after stop, because stop does update
        }
    }

    /** This method is called by AudioControlCenter, which is not implemented in the android version */
    void priorChapter() {

    }

    @Override
    public void onCompletion(MediaPlayer player) {
        player.setOnCompletionListener(null);
        this.nextChapter();
    }

    @Override
    public boolean onError(MediaPlayer player, int what, int extra) {
        //this.errorTime = System.currentTimeMillis();
        player.setOnErrorListener(null);
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

        player.reset();
        player.setOnErrorListener(this);
        //this.onErrorRecovery = true;
        //this.progressBar.setVisibility(View.VISIBLE);
        //Uri videoUri = Uri.parse(this.videoUrl);
        //this.videoView.setVideoURI(videoUri);
        return true;
    }

    private void updateMediaPlayStateTime(AudioReference reference) {
        AudioTOCChapter chapter = reference.audioChapter;
        int position = this.mediaPlayer.getCurrentPosition();
        if (chapter != null) {
            int verseNum = chapter.findVerseByPosition(1, position);
            position = chapter.findPositionOfVerse(verseNum);
        } else {
            position = (position >= 0) ? position : 0;
        }
        AudioPlayState.update(this.controller.activity, reference.toString(), position);
    }

    private void addNextChapter(AudioReference reference) {
        if (this.mediaPlayer.isPlaying()) {
            this.mediaPlayer.stop();
            this.mediaPlayer = this.nextPlayer;
            this.mediaPlayer.start();
        } else {
            this.mediaPlayer = this.nextPlayer;
        }
        this.controller.nextMediaPlayer(this.mediaPlayer);
        this.mediaPlayer.setOnCompletionListener(this);
        this.readVerseMetaData(reference);
        this.controlCenter.nowPlaying(this);
    }

    private void preFetchNextChapter(AudioReference reference) {
        this.nextReference = reference.nextChapter();
        if (this.nextReference != null) {
            PreFetchCompletion handler = new PreFetchCompletion();
            AwsS3Cache.shared().readFile(this.nextReference.getS3Bucket(),
                    this.nextReference.getS3Key(),
                    Integer.MAX_VALUE,
                    handler);
        } else {
            nextPlayer = null;
        }
    }
    class PreFetchCompletion implements CompletionHandler {
        @Override
        public void completed(Object result) {
            if (result instanceof File) {
                File file = (File) result;
                nextPlayer = initPlayer(file);
                mediaPlayer.setNextMediaPlayer(nextPlayer);
            }
        }
        @Override
        public void failed(Throwable exception) {
            Log.d(TAG, "NextReadFile Failed " + exception.toString());
        }
    }

    private void readVerseMetaData(AudioReference reference) {
        AudioTOCBible reader = reference.tocAudioBook.testament.bible;
        AudioTOCChapter chapter = reader.readVerseAudio(reference.damId(), reference.bookId(), reference.chapterNum());
        reference.audioChapter = chapter;
        if (chapter == null) {
           Log.d(TAG, "Unable to read verse position data");
        }
    }
}
