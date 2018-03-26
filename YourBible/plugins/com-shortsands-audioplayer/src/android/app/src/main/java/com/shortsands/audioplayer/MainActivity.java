package com.shortsands.audioplayer;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import com.shortsands.aws.AwsS3;

public class MainActivity extends AppCompatActivity {

    private static String TAG = "MainActivity";
    AudioBibleController audioController = AudioBibleController.shared(this);

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
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

        this.audioController.present(readBook, readChapter);//, complete: { error in
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
}
