package com.shortsands.audioplayer;

import android.app.Activity;
import android.media.MediaPlayer;
import android.util.Log;
import com.shortsands.aws.AwsS3;
import java.util.HashMap;
/**
 * Created by garygriswold on 8/30/17.
 */

public class AudioBibleController {

    private static String TAG = "AudioBibleController";

    public Activity activity;
    private AudioBibleController that;
    private AudioBible audioBible;
    private AudioBibleView readerView;

    public AudioBibleController(Activity activity) {
        this.activity = activity;
        AwsS3.initialize("us-west-2", activity);
    }

    public void present() {
        this.that = this;

        MetaDataReader metaData = new MetaDataReader(this.activity);
        MetaDataReaderResponse response = new MetaDataReaderResponse();
        metaData.read("ENG", "audio", response);
    }

    class MetaDataReaderResponse implements CompletionHandler {

        public void completed(Object result, Object attachment) {
            if (result instanceof HashMap) {
                HashMap<String, TOCAudioBible> metaData = (HashMap<String, TOCAudioBible>)result;
                TOCAudioBible bible = metaData.get("DEMO");
                TOCAudioBook book = bible.booksById.get("TST");

                Reference reference = new Reference(bible.damId, book.sequence, book.bookId, "001", "mp3");
                audioBible = new AudioBible(that, bible, reference);
                readerView = new AudioBibleView(that, audioBible);

                audioBible.beginStreaming();
                //reader.beginDownload()
                // reader.beginLocal()
            }
        }
        public void failed(Throwable exception, Object attachment) {
            Log.e(TAG, "MetaDataReader failed " + exception.toString());
        }
    }

    public void playHasStarted(MediaPlayer player) {
        if (this.readerView != null) {
            this.readerView.startPlay(player);
        }
    }

    public void playHasStopped() {
        if (this.readerView != null) {
            this.readerView.stopPlay();
            this.readerView = null;
        }
    }

    public void appHasExited() {
        this.audioBible.stop();
    }
}