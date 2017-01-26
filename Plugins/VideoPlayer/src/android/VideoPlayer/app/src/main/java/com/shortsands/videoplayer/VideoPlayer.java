package com.shortsands.videoplayer;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.MediaController;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.VideoView;
/**
 * Created by garygriswold on 1/26/17.
 * This is based up the following plugin:
 * https://github.com/nchutchind/cordova-plugin-streaming-media
 */
public class VideoPlayer extends Activity implements
        MediaPlayer.OnCompletionListener, MediaPlayer.OnPreparedListener,
        MediaPlayer.OnErrorListener, MediaPlayer.OnBufferingUpdateListener {
    private String TAG = getClass().getSimpleName();
    private VideoView videoView = null;
    private MediaController mediaController = null;
    private ProgressBar progressBar = null;
    private String videoUrl;
    private Boolean shouldAutoClose = true;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.requestWindowFeature(Window.FEATURE_NO_TITLE);
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

        //Bundle b = getIntent().getExtras();
        //mVideoUrl = b.getString("mediaUrl");
        //mShouldAutoClose = b.getBoolean("shouldAutoClose");
        this.videoUrl = "https://arc.gt/1e62h?apiSessionId=587858aea460f2.62190595";
        this.shouldAutoClose = this.shouldAutoClose == null ? true : this.shouldAutoClose;

        RelativeLayout relLayout = new RelativeLayout(this);
        relLayout.setBackgroundColor(Color.BLACK);
        RelativeLayout.LayoutParams relLayoutParam = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.MATCH_PARENT);
        relLayoutParam.addRule(RelativeLayout.CENTER_IN_PARENT, RelativeLayout.TRUE);
        this.videoView = new VideoView(this);
        this.videoView.setLayoutParams(relLayoutParam);
        relLayout.addView(this.videoView);

        // Create progress throbber
        this.progressBar = new ProgressBar(this);
        this.progressBar.setIndeterminate(true);
        // Center the progress bar
        RelativeLayout.LayoutParams pblp = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
        pblp.addRule(RelativeLayout.CENTER_IN_PARENT, RelativeLayout.TRUE);
        this.progressBar.setLayoutParams(pblp);
        // Add progress throbber to view
        relLayout.addView(this.progressBar);
        this.progressBar.bringToFront();

        //setOrientation(b.getString("orientation"));
        setOrientation("landscape");

        setContentView(relLayout, relLayoutParam);

        play();
    }

    private void play() {
        this.progressBar.setVisibility(View.VISIBLE);
        Uri videoUri = Uri.parse(this.videoUrl);
        try {
            this.videoView.setOnCompletionListener(this);
            this.videoView.setOnPreparedListener(this);
            this.videoView.setOnErrorListener(this);
            this.videoView.setVideoURI(videoUri);
            this.mediaController = new MediaController(this);
            this.mediaController.setAnchorView(this.videoView);
            this.mediaController.setMediaPlayer(this.videoView);
            this.videoView.setMediaController(this.mediaController);
        } catch (Throwable t) {
            Log.d(TAG, t.toString());
        }
    }

    private void setOrientation(String orientation) {
        if ("landscape".equals(orientation)) {
            this.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
        }else if("portrait".equals(orientation)) {
            this.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        }
    }

    private Runnable checkIfPlaying = new Runnable() {
        @Override
        public void run() {
            if (videoView.getCurrentPosition() > 0) {
                // Video is not at the very beginning anymore.
                // Hide the progress bar.
                progressBar.setVisibility(View.GONE);
            } else {
                // Video is still at the very beginning.
                // Check again after a small amount of time.
                videoView.postDelayed(checkIfPlaying, 100);
            }
        }
    };

    @Override
    public void onPrepared(MediaPlayer mediaPlayer) {
        Log.d(TAG, "Stream is prepared");
        mediaPlayer.setOnBufferingUpdateListener(this);
        this.videoView.requestFocus();
        this.videoView.start();
        this.videoView.postDelayed(checkIfPlaying, 0);
    }

    private void pause() {
        Log.d(TAG, "Pausing video.");
        this.videoView.pause();
    }

    private void stop() {
        Log.d(TAG, "Stopping video.");
        this.videoView.stopPlayback();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        stop();
    }

    private void wrapItUp(int resultCode, String message) {
        Intent intent = new Intent();
        intent.putExtra("message", message);
        setResult(resultCode, intent);
        finish();
    }

    public void onCompletion(MediaPlayer mediaPlayer) {
        stop();
        if (mShouldAutoClose) {
            wrapItUp(RESULT_OK, null);
        }
    }

    public boolean onError(MediaPlayer mediaPlayer, int what, int extra) {
        StringBuilder sb = new StringBuilder();
        sb.append("MediaPlayer Error: ");
        switch (what) {
            case MediaPlayer.MEDIA_ERROR_NOT_VALID_FOR_PROGRESSIVE_PLAYBACK:
                sb.append("Not Valid for Progressive Playback");
                break;
            case MediaPlayer.MEDIA_ERROR_SERVER_DIED:
                sb.append("Server Died");
                break;
            case MediaPlayer.MEDIA_ERROR_UNKNOWN:
                sb.append("Unknown");
                break;
            default:
                sb.append(" Non standard (");
                sb.append(what);
                sb.append(")");
        }
        sb.append(" (" + what + ") ");
        sb.append(extra);
        Log.e(TAG, sb.toString());

        wrapItUp(RESULT_CANCELED, sb.toString());
        return true;
    }

    public void onBufferingUpdate(MediaPlayer mediaPlayer, int percent) {
        Log.d(TAG, "onBufferingUpdate : " + percent + "%");
    }

    @Override
    public void onBackPressed() {
        // If we're leaving, let's finish the activity
        wrapItUp(RESULT_OK, null);
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        // The screen size changed or the orientation changed... don't restart the activity
        super.onConfigurationChanged(newConfig);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (this.mediaController != null)
            this.mediaController.show();
        return false;
    }
}
