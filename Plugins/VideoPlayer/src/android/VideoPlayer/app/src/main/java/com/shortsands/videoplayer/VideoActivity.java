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
    private final static String TAG = "VideoActivity";
    private VideoView videoView;
    private MediaController mediaController;
    private MediaPlayer mediaPlayer;
    private ProgressBar progressBar;
    private String videoUrl;
    private Uri videoUri;
    private int currentPosition = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, "onCreate CALLED " + System.currentTimeMillis());

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
        
        if (savedInstanceState != null) {
	        this.initializeVideo(savedInstanceState);
        } else {
	        this.initializeVideo(getIntent().getExtras());
        }
        
        this.videoView.setOnPreparedListener(this);
        this.videoView.setOnCompletionListener(this);
        //this.videoView.setOnInfoListener(this); requires SDK 17
        this.videoView.setOnErrorListener(this);
        
        this.mediaController = new MediaController(this);
        this.mediaController.setAnchorView(this.videoView);
        this.mediaController.setMediaPlayer(this.videoView);
        this.videoView.setMediaController(this.mediaController);
    }
    
    @Override 
    protected void onRestoreInstanceState(Bundle savedInstanceState) {
	    Log.d(TAG, "onRestoreInstanceState CALLED");
    	super.onRestoreInstanceState(savedInstanceState);
		this.initializeVideo(savedInstanceState);
	}
	
	private void initializeVideo(Bundle bundle) {
		this.videoUrl = bundle.getString("videoUrl");
        this.videoUri = Uri.parse(videoUrl);
        int seekSec = bundle.getInt("seekSec");
        this.currentPosition = seekSec * 1000;
	}
	
	@Override
    protected void onSaveInstanceState(Bundle bundle) {
	    Log.d(TAG, "onSaveInstanceState CALLED ");
	    super.onSaveInstanceState(bundle);
		bundle.putString("videoUrl", this.videoUrl);
		bundle.putInt("seekSec", this.videoView.getCurrentPosition() / 1000);   
     }

    @Override
    protected void onRestart() {
        super.onRestart();
        Log.d(TAG, "onRestart CALLED " + System.currentTimeMillis());
    }
    
    @Override
    protected void onStart() {
        super.onStart();
        Log.d(TAG, "onStart CALLED " + System.currentTimeMillis());
    }

    @Override
    protected void onResume() {
        super.onResume();
        Log.d(TAG, "onResume CALLED " + System.currentTimeMillis());
        this.progressBar.setVisibility(View.VISIBLE);
        this.videoView.setVideoURI(this.videoUri);
    }

	/**
	* Activity docs recommend that this method be used for persistent storage.
	* Possibly, I should store data in a sqlite database here, instead of 
	* returning values to the plugin.
	*/
    @Override
    protected void onPause() {
        super.onPause();
        Log.d(TAG, "onPause CALLED " + System.currentTimeMillis());
        this.currentPosition = this.videoView.getCurrentPosition();
        
        this.videoView.stopPlayback();
        if (this.mediaPlayer != null) {
        	this.mediaPlayer.release();
        	this.mediaPlayer = null;
        }
    }
    
    /*
	 * Possible persistence solution to be used here in onPause
	 * SharedPreferences prefs = getSharedPreferences(videoId);
	 * this.videoUrl = prefs.getString(“videoUrl”, defaultUrl);
	 * this.seekSec = prefs.getInt(“seekSec”, default)
	 * Where videoId is a language independent identifier of the video
	 * Used this way the original start of the video would only need
	 * [videoId, videoUrl].
	 * Note change the calling program as well.
	 */

    @Override
    protected void onStop() {
        super.onStop();
        Log.d(TAG, "onStop CALLED " + System.currentTimeMillis());
    }

    @Override
    protected void onDestroy() {
	   	super.onDestroy();
        Log.d(TAG, "onDestroy CALLED " + System.currentTimeMillis());
    }

	@Override
    public void onPrepared(MediaPlayer mp) {
        Log.d(TAG, "onPrepared CALLED " + System.currentTimeMillis());
        this.mediaPlayer = mp;
        this.mediaPlayer.setOnBufferingUpdateListener(this);
	    this.videoView.start();
        if (this.currentPosition > 0) {
	       	this.mediaPlayer.setOnSeekCompleteListener(this);
	        this.videoView.seekTo(this.currentPosition);
        } else {
			this.actualStartVideo();
        }
    }
    
    public void onSeekComplete(MediaPlayer mp) {
        Log.d(TAG, "onSeekComplete CALLED " + System.currentTimeMillis());
        this.actualStartVideo();
    }
    
    private void actualStartVideo() {
	    Log.d(TAG, "actualStartVideo " + System.currentTimeMillis());
	    this.videoView.requestFocus();
	    //this.videoView.start();
	    this.progressBar.setVisibility(View.GONE);
    }

    public boolean onError(MediaPlayer mediaPlayer, int what, int extra) {
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
                message = "MEDIA ERROR UNKNOWN";
                break;
            default:
                message = "Unknown Error " + what;
        }
        Log.e(TAG, "onError " + message + " " + extra);

        this.wrapItUp(Activity.RESULT_CANCELED, message);
        return true;
    }

    public boolean onInfo(MediaPlayer mediaPlayer, int what, int extra) {
        String message;
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

    public void onCompletion(MediaPlayer mediaPlayer) {
        Log.d(TAG, "onCompletion CALLED " + System.currentTimeMillis());
        this.wrapItUp(Activity.RESULT_OK, null);
    }

	/**
	* Do not call super.onBackPressed, it will call setResult
	*/
    @Override
    public void onBackPressed() {
        Log.d(TAG, "onBackPressed CALLED " + System.currentTimeMillis());
        // If we're leaving, let's finish the activity
        this.wrapItUp(Activity.RESULT_OK, null);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        Log.d(TAG, "onTouchEvent CALLED " + System.currentTimeMillis());
        if (this.mediaController != null)
            this.mediaController.show();
        return false;
    }

    private void wrapItUp(int resultCode, String message) {
        Log.d(TAG, "wrapItUp CALLED " + System.currentTimeMillis());
        Bundle bundle = new Bundle();
		bundle.putString("videoUrl", this.videoUrl);
		bundle.putInt("seekSec", this.videoView.getCurrentPosition() / 1000);
		bundle.putString("message", message);
        Intent intent = new Intent();
        intent.putExtras(bundle);
        setResult(resultCode, intent);
        finish(); // Calls onPause
    }
}