package com.shortsands.audioplayer;

import android.content.Context;
import android.app.Activity;
import android.app.Service;
import android.app.IntentService;

import com.shortsands.aws.AwsS3;
/**
 * Created by garygriswold on 8/30/17.
 */

public class AudioBibleController {

    public Activity activity;
    public String region;
    private AudioBibleView readerView;

    public AudioBibleController(Activity activity) {
        this.activity = activity;
        this.region = "us-west-2";
        AwsS3.initialize(this.region, activity);
    }

    public void present() { // one parameter view
        AudioBible audioBible = new AudioBible(this, null, null);
        this.readerView = new AudioBibleView(this, audioBible);
        audioBible.beginStreaming();

        /* iOS
        view.backgroundColor = .blue // This is for Testing

        AwsS3.region = "us-west-2"
        let metaData = MetaDataReader()
        metaData.read(languageCode: "ENG", mediaType: "audio", readComplete: { tocDictionary in

            //let tocAudioBible = tocDictionary["ENGWEBN2DA"]
            let tocAudioBible = tocDictionary["DEMO"]
            if let tocBible = tocAudioBible {
                //let metaBook = tocBible.booksById["JHN"]
                let metaBook = tocBible.booksById["TST"]
                if let book = metaBook {

                    let reference = Reference(damId: tocBible.damId, sequence: book.sequence, book: book.bookId,
                                              chapter: "001", fileType: "mp3")
                    let reader = AudioBible(controller: self, tocBible: tocBible, reference: reference)
                    self.readerView = AudioBibleView(view: view, audioBible: reader)

                    reader.beginStreaming()
                    //reader.beginDownload()
                    //reader.beginLocal()
                }
            }
        })

         */
    }

    public void playHasStarted() {
        if (this.readerView != null) {
            this.readerView.startPlay();
        }
    }

    public void playHasStopped() {
        if (this.readerView != null) {
            this.readerView.stopPlay();
            this.readerView = null;
        }
    }
}