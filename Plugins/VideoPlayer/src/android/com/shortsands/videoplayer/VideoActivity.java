package com.shortsands.videoplayer;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import com.google.android.exoplayer2.ExoPlaybackException;
import com.google.android.exoplayer2.ExoPlayer;
import com.google.android.exoplayer2.ExoPlayerFactory;
import com.google.android.exoplayer2.DefaultLoadControl;
import com.google.android.exoplayer2.LoadControl;
import com.google.android.exoplayer2.SimpleExoPlayer;
import com.google.android.exoplayer2.Timeline;
import com.google.android.exoplayer2.source.MediaSource;
import com.google.android.exoplayer2.source.TrackGroupArray;
import com.google.android.exoplayer2.source.hls.HlsMediaSource;
import com.google.android.exoplayer2.trackselection.AdaptiveTrackSelection;
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector;
import com.google.android.exoplayer2.trackselection.TrackSelection;
import com.google.android.exoplayer2.trackselection.TrackSelectionArray;
import com.google.android.exoplayer2.trackselection.TrackSelector;
import com.google.android.exoplayer2.ui.SimpleExoPlayerView;
import com.google.android.exoplayer2.upstream.BandwidthMeter;
import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.upstream.DefaultBandwidthMeter;
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory;
import com.google.android.exoplayer2.util.Util;

/**
 * Created by garygriswold on 4/28/2016
 */
public class VideoActivity extends Activity implements ExoPlayer.EventListener {

    private final static String TAG = "VideoActivity";
    private final static boolean DEBUG = false;
    private ProgressBar progressBar;
	private SimpleExoPlayer player;
	private SimpleExoPlayerView playerView;
	private EventLogger eventLogger;
	private boolean videoPlaybackComplete = false;
        
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, "onCreate CALLED " + System.currentTimeMillis());

        Window window = this.getWindow();
        window.requestFeature(Window.FEATURE_NO_TITLE);
        window.setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

        RelativeLayout relativeLayout = new RelativeLayout(this);
        relativeLayout.setBackgroundColor(Color.BLACK);
        RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, 
        		RelativeLayout.LayoutParams.MATCH_PARENT);
        layoutParams.addRule(RelativeLayout.CENTER_IN_PARENT, RelativeLayout.TRUE);

		this.playerView = new SimpleExoPlayerView(this);
		relativeLayout.addView(this.playerView);

        // Create startup progress animation
        this.progressBar = new ProgressBar(this);
        this.progressBar.setIndeterminate(true);
        RelativeLayout.LayoutParams progLayout = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT,
        		RelativeLayout.LayoutParams.WRAP_CONTENT);
        progLayout.addRule(RelativeLayout.CENTER_IN_PARENT, RelativeLayout.TRUE);
        this.progressBar.setLayoutParams(progLayout);
        relativeLayout.addView(this.progressBar);
        this.progressBar.bringToFront();

        setContentView(relativeLayout);
    }

    @Override
    protected void onResume() {
        super.onResume();
        Log.d(TAG, "onResume CALLED " + System.currentTimeMillis());
    	this.progressBar.setVisibility(View.VISIBLE);    
        
        // 1. Get Id and Url
        Bundle bundle = getIntent().getExtras();
        String videoId = bundle.getString("videoId");
        String videoUrl = bundle.getString("videoUrl");
        VideoPersistence videoState = VideoPersistence.retrieve(this, videoId, videoUrl);
	    	    
	    // 2. Create a default TrackSelector
		Handler mainHandler = new Handler();
		BandwidthMeter bandwidthMeter = new DefaultBandwidthMeter();
		TrackSelection.Factory videoTrackSelectionFactory = 
				new AdaptiveTrackSelection.Factory(bandwidthMeter);
		TrackSelector trackSelector = 
				new DefaultTrackSelector(videoTrackSelectionFactory);
		
		// 3. Create the player
		LoadControl loadControl = new DefaultLoadControl();
		this.player = ExoPlayerFactory.newSimpleInstance(getApplicationContext(), trackSelector, loadControl);
		this.player.setPlayWhenReady(true);
		this.player.addListener(this);
		
		// 4. Create Logger
		if (DEBUG) {
			this.eventLogger = new EventLogger();
			this.player.setAudioDebugListener(this.eventLogger);
			this.player.setVideoDebugListener(this.eventLogger);
			this.player.setMetadataOutput(this.eventLogger);
		}
				
		// 5. Bind the player to the view
		this.playerView.requestFocus();
		this.playerView.setPlayer(this.player);

		// Measures bandwidth during playback. Can be null if not required.
		DefaultBandwidthMeter bandwidthMeter2 = new DefaultBandwidthMeter();
		
		// Produces DataSource instances through which media data is loaded.
		DataSource.Factory dataSourceFactory = new DefaultDataSourceFactory(this,
			Util.getUserAgent(this, "ShortSands"), bandwidthMeter2);
			
		// 6. This is the MediaSource representing the media to be played.
        Uri videoUri = Uri.parse(videoState.videoUrl);
		MediaSource videoSource = new HlsMediaSource(videoUri, dataSourceFactory, mainHandler, this.eventLogger);

		// 7. Prepare the player with the source.
		long seekTime = videoState.currentPosition;
		if (seekTime > 100) {
			this.player.seekTo(seekTime);
			this.player.prepare(videoSource, false, false);
		} else {
			this.player.prepare(videoSource);
		}	    
    }
    
	/**
	* Activity docs recommend that this method be used for persistent storage.
	* SharedPreferences is used to save the current location in the current video
	*/
    @Override
    protected void onPause() {
        super.onPause();
        Log.d(TAG, "onPause CALLED " + System.currentTimeMillis());

        if (this.videoPlaybackComplete) {
	        VideoPersistence.clear(this);
        } else {
	        VideoPersistence.update(this, this.player.getCurrentPosition());
        }
        
		if (this.player != null) {
		    this.player.release();
		    this.player = null;
			this.eventLogger = null;
	    }
    }
    
    @Override
    protected void onDestroy() {
	    super.onDestroy();
	    Log.d(TAG, "onDestroy CALLED " + System.currentTimeMillis());
		this.playerView = null;
    }
    

    
//    private int backupSeek() {
//	    if (this.onErrorRecovery) {
//		    this.onErrorRecovery = false;
//		    int recovTime = this.backupPosition + (int)(this.errorTime - this.backupTime);
//			return(recovTime);
//	    } else {
//			long duration = new Date().getTime() - this.timestamp.getTime();
//			int backupMs = Long.toString(duration).length() * 1000; // could multiply by a factor here
//			int seekTime = this.currentPosition - backupMs;
//			Log.d(TAG, "current and seekTime " + this.currentPosition + " " + seekTime);
//			return(seekTime);
//		}
//	}

	/**
	* Do not call super.onBackPressed, it will call setResult
	*/
    @Override
    public void onBackPressed() {
        Log.d(TAG, "onBackPressed CALLED " + System.currentTimeMillis());
        this.wrapItUp(Activity.RESULT_OK, null);
    }

    private void wrapItUp(int resultCode, String message) {
        Log.d(TAG, "wrapItUp CALLED " + System.currentTimeMillis());
        if (message != null) {
	        Intent intent = new Intent();
	        intent.putExtra("message", message);
			setResult(resultCode, intent);
        } else {
        	setResult(resultCode);
        }
        finish(); // Calls onPause
    }
    
 	/**
	* Handler methods for ExoPlayer.Listener
	*/
	@Override
	public void onLoadingChanged(boolean isLoading) {
    	Log.d(TAG, "onLoadingChanged [" + isLoading + "]");
	}
	@Override
	public void onPlayerError(ExoPlaybackException e) {
		Log.e(TAG, "************** onPlayerError ", e);
	}
	@Override
	public void onPlayerStateChanged(boolean playWhenReady, int state) {
		String message;
		switch (state) {
			case ExoPlayer.STATE_BUFFERING:
				message = "Buffering";
				break;
			case ExoPlayer.STATE_ENDED:
				message = "Ended";
				this.videoPlaybackComplete = true;
				this.wrapItUp(Activity.RESULT_OK, null);
				break;
			case ExoPlayer.STATE_IDLE:
				message = "Idle";
				break;
			case ExoPlayer.STATE_READY:
				message = "Ready";
				this.progressBar.setVisibility(View.GONE);
				break;
			default:
				message = "Unknown";
		}
		Log.d(TAG, "onPlayerStateChanged [ " + playWhenReady + ", " + state + ", " + message + " ]");
	}
 	@Override
 	public void onPositionDiscontinuity() {
 		Log.d(TAG, "onPositionDiscontinuity CALLED");
	}
	@Override
	public void onTimelineChanged(Timeline timeline, Object manifest) {
		Log.d(TAG, "onTimelineChanged CALLED");
	}
	@Override
	public void onTracksChanged(TrackGroupArray ignored, TrackSelectionArray trackSelections) {
		Log.d(TAG, "onTracksChanged CALLED");
	}
}