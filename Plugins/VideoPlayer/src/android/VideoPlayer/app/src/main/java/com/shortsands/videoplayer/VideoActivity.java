package com.shortsands.videoplayer;

import android.app.Activity;
import android.content.Intent;
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
public class VideoActivity extends Activity implements
        MediaPlayer.OnCompletionListener, MediaPlayer.OnPreparedListener,
        MediaPlayer.OnErrorListener, MediaPlayer.OnInfoListener,
        MediaPlayer.OnSeekCompleteListener, MediaPlayer.OnBufferingUpdateListener {
    private String TAG = getClass().getSimpleName();
    private VideoView videoView = null;
    private MediaController mediaController = null;
    private ProgressBar progressBar = null;
    private int currentPosition = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, "onCreate CALLED " + System.currentTimeMillis());

        //Bundle b = getIntent().getExtras();
        //mVideoUrl = b.getString("mediaUrl");
        //mShouldAutoClose = b.getBoolean("shouldAutoClose");
        //this.videoUrl = "https://arc.gt/1e62h?apiSessionId=587858aea460f2.62190595";
        //this.shouldAutoClose = this.shouldAutoClose == null ? true : this.shouldAutoClose;

        Window window = this.getWindow();
        window.requestFeature(Window.FEATURE_NO_TITLE);
        window.setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

        RelativeLayout relativeLayout = new RelativeLayout(this);
        relativeLayout.setBackgroundColor(Color.BLACK);
        RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.MATCH_PARENT);
        layoutParams.addRule(RelativeLayout.CENTER_IN_PARENT, RelativeLayout.TRUE);
        this.videoView = new VideoView(this);
        this.videoView.setLayoutParams(layoutParams);
        relativeLayout.addView(this.videoView);

        // Create startup progress animation
        this.progressBar = new ProgressBar(this);
        this.progressBar.setIndeterminate(true);
        RelativeLayout.LayoutParams progLayout = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
        progLayout.addRule(RelativeLayout.CENTER_IN_PARENT, RelativeLayout.TRUE);
        this.progressBar.setLayoutParams(progLayout);
        relativeLayout.addView(this.progressBar);
        this.progressBar.bringToFront();

        setContentView(relativeLayout);
    }

    @Override
    protected void onStart() {
        super.onStart();
        Log.d(TAG, "onStart CALLED " + System.currentTimeMillis());
        this.videoView.setOnPreparedListener(this);
        this.videoView.setOnCompletionListener(this);
        //this.videoView.setOnInfoListener(this); requires SDK 17
        this.videoView.setOnErrorListener(this);

        String url = "https://arc.gt/1e62h?apiSessionId=587858aea460f2.62190595";
        Uri videoUri = Uri.parse(url);
        this.videoView.setVideoURI(videoUri);
        this.mediaController = new MediaController(this);
        this.mediaController.setAnchorView(this.videoView);
        this.mediaController.setMediaPlayer(this.videoView);
        this.videoView.setMediaController(this.mediaController);
    }

    @Override
    protected void onRestart() {
        super.onRestart();
        Log.d(TAG, "onRestart CALLED " + System.currentTimeMillis());
    }

    @Override
    protected void onResume() {
        super.onResume();
        Log.d(TAG, "onResume CALLED " + System.currentTimeMillis());
        this.progressBar.setVisibility(View.VISIBLE);
        if (this.currentPosition > 0) {
            this.videoView.seekTo(this.currentPosition);
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        Log.d(TAG, "onPause CALLED " + System.currentTimeMillis());
        this.currentPosition = this.videoView.getCurrentPosition();
        this.videoView.stopPlayback();
    }

    @Override
    protected void onStop() {
        super.onStop();
        Log.d(TAG, "onStop CALLED " + System.currentTimeMillis());
    }

    @Override
    protected void onDestroy() {
        Log.d(TAG, "onDestroy CALLED " + System.currentTimeMillis());
        super.onDestroy();
    }
/*
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
*/
    public void onPrepared(MediaPlayer mediaPlayer) {
        Log.d(TAG, "onPrepared CALLED " + System.currentTimeMillis());
        mediaPlayer.setOnBufferingUpdateListener(this);
        mediaPlayer.setOnSeekCompleteListener(this);
        this.videoView.requestFocus();
        this.videoView.start();
        //this.videoView.postDelayed(checkIfPlaying, 0);
        this.progressBar.setVisibility(View.GONE);
    }

    public boolean onError(MediaPlayer mediaPlayer, int what, int extra) {
        String message = "";
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
                message = "MEDIA ERROR UNKNOWN";
                break;
            default:
                message = "Unknown Error " + what;
        }
        Log.e(TAG, "onError " + message + " " + extra);

        wrapItUp(RESULT_CANCELED, message);
        return true;
    }

    public boolean onInfo(MediaPlayer mediaPlayer, int what, int extra) {
        String message = "";
        switch(what) {
            case MediaPlayer.MEDIA_INFO_UNKNOWN:
                message = "MEDIA INFO UNKNOWN";
                break;
            case MediaPlayer.MEDIA_INFO_VIDEO_TRACK_LAGGING:
                message = "MEDIA INFO VIDEO TRACK LAGGING";
                break;
            case MediaPlayer.MEDIA_INFO_VIDEO_RENDERING_START:
                message = "MEDIA INFO VIDEO RENDERING START";
                break;
            case MediaPlayer.MEDIA_INFO_BUFFERING_START:
                message = "MEDIA INFO BUFFERING START";
                break;
            case MediaPlayer.MEDIA_INFO_BUFFERING_END:
                message = "MEDIA INFO BUFFERING END";
                break;
            //case MediaPlayer.MEDIA_INFO_NETWORK_BANDWIDTH:
            //    //(703) - bandwidth information is available (as extra kbps)
            //    break;
            case MediaPlayer.MEDIA_INFO_BAD_INTERLEAVING:
                message = "MEDIA INFO BAD INTERLEAVING";
                break;
            case MediaPlayer.MEDIA_INFO_NOT_SEEKABLE:
                message = "MEDIA INFO NOT SEEKABLE";
                break;
            case MediaPlayer.MEDIA_INFO_METADATA_UPDATE:
                message = "MEDIA INFO METADATA UPDATE";
                break;
            case MediaPlayer.MEDIA_INFO_UNSUPPORTED_SUBTITLE:
                message = "MEDIA INFO UNSUPPORTED SUBTITLE";
                break;
            case MediaPlayer.MEDIA_INFO_SUBTITLE_TIMED_OUT:
                message = "MEDIA INFO SUBTITLE TIMED OUT";
                break;
            default:
                message = "Unknown Info " + what;
                break;
        }
        Log.d(TAG, "onInfo " + message + " " + extra);
        return(true);
    }

    public void onBufferingUpdate(MediaPlayer mediaPlayer, int percent) {
        Log.d(TAG, "onBufferingUpdate : " + percent + "%");
    }

    public void onSeekComplete(MediaPlayer mediaPlayer) {
        Log.d(TAG, "onSeekComplete CALLED");
    }

    public void onCompletion(MediaPlayer mediaPlayer) {
        Log.d(TAG, "onCompletion CALLED");
        this.videoView.stopPlayback();
        wrapItUp(RESULT_OK, null);
    }

    @Override
    public void onBackPressed() {
        Log.d(TAG, "onBackPressed CALLED");
        // If we're leaving, let's finish the activity
        wrapItUp(RESULT_OK, null);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        Log.d(TAG, "onTouchEvent CALLED");
        if (this.mediaController != null)
            this.mediaController.show();
        return false;
    }

    private void wrapItUp(int resultCode, String message) {
        Log.d(TAG, "wrapItUp CALLED");
        Intent intent = new Intent();
        intent.putExtra("message", message);
        setResult(resultCode, intent);
        finish(); // Calls OnDestroy
    }
}