package com.shortsands.audioplayer;

import android.app.Activity;
import android.media.MediaPlayer;
import android.util.Log;
import com.shortsands.aws.AwsS3;
import com.shortsands.aws.CompletionHandler;
import java.util.HashMap;
/**
 * Created by garygriswold on 8/30/17.
 */

public class AudioBibleController {

    private static final String TAG = "AudioBibleController";

    private static AudioBibleController instance = null;
    public static AudioBibleController shared(Activity activity)  {
        if (AudioBibleController.instance == null) {
            AudioBibleController.instance = new AudioBibleController(activity);
        }
        return AudioBibleController.instance;
    }

    final Activity activity;
    private String fileType;
    private AudioTOCBible metaDataReader;
    private AudioBible audioBible;
    private AudioBibleView audioBibleView;
    private AudioSession audioSession;

    private AudioBibleController(Activity activity) {
        this.activity = activity;
        this.fileType = "mp3";
    }

    public String findAudioVersion(String version, String silLang) {
        this.metaDataReader = new AudioTOCBible(this.activity, version, silLang);
        this.metaDataReader.read();
        StringBuilder bookIdList = new StringBuilder();
        if (this.metaDataReader.oldTestament != null) {
            bookIdList.append(this.metaDataReader.oldTestament.getBookList());
        }
        if (this.metaDataReader.newTestament != null) {
            bookIdList.append(this.metaDataReader.newTestament.getBookList());
        }
        return bookIdList.toString();
    }

    public boolean isPlaying() {
        boolean result = false;
        if (this.audioBible != null && this.audioBibleView != null) {
            result = this.audioBible.isPlaying() || this.audioBibleView.audioBibleActive();
        }
        return result;
    }

    // should this return an error code in order to be consistent to iOS?
    public void present(String bookId, int chapterNum) {

        this.audioBible = AudioBible.shared(this);
        this.audioBibleView = AudioBibleView.shared(this, this.audioBible);
        this.audioSession = AudioSession.shared(this.activity, this.audioBibleView);
        //this.completionHandler = complete // something is required here for cordova

        if (this.audioSession.startAudioSession()) {

            if (!this.isPlaying()) {
                if (this.metaDataReader != null) {
                    AudioTOCBook meta = this.metaDataReader.findBook(bookId);
                    if (meta != null) {
                        AudioReference ref = AudioReference.factory(meta, chapterNum, this.fileType);
                        this.audioBible.beginReadFile(ref);
                    }
                }
            }
        }
    }

    /**
     * This is called when the Audio must be stopped externally, such as when a Video is started.
     */
    public void stop() {
        if (this.audioBible != null) {
            this.audioBible.stop();
        }
    }

    void playHasStarted(MediaPlayer player) {
        if (this.audioBibleView != null) {
            this.audioBibleView.startPlay(player);
        }
    }

    void nextMediaPlayer(MediaPlayer player) {
        if (this.audioBibleView != null) {
            this.audioBibleView.startNewPlayer(player);
        }
    }

    void playHasStopped() {
        if (this.audioBibleView != null) {
            this.audioBibleView.stopPlay();
            this.audioBibleView = null;
        }
        //this.completionHandler(null); // Is this needed for cordova?
        this.audioSession.stopAudioSession();
    }

    /**
     * This method is called by an outside controller to indicate that App has stopped.
     */
    public void appHasExited() {
        this.audioBible.stop();
    }
}