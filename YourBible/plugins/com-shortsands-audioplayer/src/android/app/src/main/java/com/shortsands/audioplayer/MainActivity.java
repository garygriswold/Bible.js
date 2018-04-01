package com.shortsands.audioplayer;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.webkit.WebView;
import com.shortsands.aws.AwsS3;
import com.shortsands.aws.CompletionHandler;

public class MainActivity extends AppCompatActivity {

    private static String TAG = "MainActivity";
    private AudioBibleController audioController = AudioBibleController.shared(this);
    private WebView webview;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.webview = new WebView(this);
        setContentView(this.webview);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onResume() {
        super.onResume();
        Log.d(TAG, "*** onResume is called.");

        AwsS3.initialize("us-east-1", this);
        String readVersion = "ERV-ENG";//KJVPD"//ESV"
        String readLang = "eng";
        String readBook = "JHN";
        int readChapter = 2;
        String bookIdList = this.audioController.findAudioVersion(readVersion, readLang);
        Log.d(TAG,"BOOKS: " + bookIdList);

        AudioPresentCompletion complete = new AudioPresentCompletion();
        this.audioController.present(this.webview, readBook, readChapter, complete);
        // print("ViewController.present did finish error: \(String(describing: error))")
    }

    /**
     * onPause is called here when the App is quit by using any of the three
     * buttons at the bottom, or the lock button.
     */
    @Override
    public void onPause() {
        super.onPause();
        Log.d(TAG, "*** onPause is called.");
        if (this.audioController != null) {
            this.audioController.appHasExited();
        }
    }

    class AudioPresentCompletion implements CompletionHandler {
        @Override
        public void completed(Object result) {
            Log.d(TAG, "AudioPlayer.present has completed OK.");
        }
        @Override
        public void failed(Throwable exception) {
            Log.d(TAG, "AudioPlayer.present exception " + exception.toString());
        }
    }

}
