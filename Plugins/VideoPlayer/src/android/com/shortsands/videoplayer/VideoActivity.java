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
import java.util.Date;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;
import com.google.android.exoplayer2.C;
//import com.google.android.exoplayer2.DefaultRenderersFactory;
import com.google.android.exoplayer2.ExoPlaybackException;
import com.google.android.exoplayer2.ExoPlayer;
import com.google.android.exoplayer2.ExoPlayerFactory;
import com.google.android.exoplayer2.DefaultLoadControl;
import com.google.android.exoplayer2.LoadControl;
//import com.google.android.exoplayer2.PlaybackParameters;
import com.google.android.exoplayer2.SimpleExoPlayer;
import com.google.android.exoplayer2.Timeline;
import com.google.android.exoplayer2.drm.DefaultDrmSessionManager;
import com.google.android.exoplayer2.drm.DrmSessionManager;
import com.google.android.exoplayer2.drm.FrameworkMediaCrypto;
import com.google.android.exoplayer2.drm.FrameworkMediaDrm;
import com.google.android.exoplayer2.drm.HttpMediaDrmCallback;
import com.google.android.exoplayer2.drm.UnsupportedDrmException;
import com.google.android.exoplayer2.extractor.DefaultExtractorsFactory;
import com.google.android.exoplayer2.extractor.ExtractorsFactory;
import com.google.android.exoplayer2.mediacodec.MediaCodecRenderer.DecoderInitializationException;
import com.google.android.exoplayer2.mediacodec.MediaCodecUtil.DecoderQueryException;
import com.google.android.exoplayer2.source.BehindLiveWindowException;
import com.google.android.exoplayer2.source.ConcatenatingMediaSource;
import com.google.android.exoplayer2.source.ExtractorMediaSource;
import com.google.android.exoplayer2.source.MediaSource;
import com.google.android.exoplayer2.source.TrackGroupArray;
import com.google.android.exoplayer2.source.dash.DashMediaSource;
import com.google.android.exoplayer2.source.dash.DefaultDashChunkSource;
import com.google.android.exoplayer2.source.hls.HlsMediaSource;
import com.google.android.exoplayer2.source.smoothstreaming.DefaultSsChunkSource;
import com.google.android.exoplayer2.source.smoothstreaming.SsMediaSource;
import com.google.android.exoplayer2.trackselection.AdaptiveTrackSelection;
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector;
import com.google.android.exoplayer2.trackselection.MappingTrackSelector.MappedTrackInfo;
import com.google.android.exoplayer2.trackselection.TrackSelection;
import com.google.android.exoplayer2.trackselection.TrackSelectionArray;
import com.google.android.exoplayer2.trackselection.TrackSelector;
import com.google.android.exoplayer2.ui.DebugTextViewHelper;
import com.google.android.exoplayer2.ui.PlaybackControlView;
import com.google.android.exoplayer2.ui.SimpleExoPlayerView;
import com.google.android.exoplayer2.upstream.BandwidthMeter;
import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.upstream.DefaultBandwidthMeter;
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory;
import com.google.android.exoplayer2.upstream.HttpDataSource;
import com.google.android.exoplayer2.util.Util;
import java.net.CookieHandler;
import java.net.CookieManager;
import java.net.CookiePolicy;
import java.util.UUID;
/**
 * Created by garygriswold on 4/28/2016
 */
public class VideoActivity extends Activity implements ExoPlayer.EventListener {

    private final static String TAG = "VideoActivity";
    //private VideoPersistence videoPersistence = new VideoPersistence(this);
    private ProgressBar progressBar;
	private Handler mainHandler;
	private SimpleExoPlayer player;
	private SimpleExoPlayerView playerView;
	private EventLogger eventLogger;
    private String videoId;
    private String videoUrl;
//    private int currentPosition = 0;
//    private boolean videoPlaybackComplete = false;
//    private Date timestamp = new Date();
        

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

//        this.videoView = new VideoView(this);
//        this.videoView.setLayoutParams(layoutParams);
//        relativeLayout.addView(this.videoView);
		this.playerView = new SimpleExoPlayerView(this);
		//this.playerView.setLayout(layoutParams);
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
        Bundle bundle = getIntent().getExtras();
		this.videoUrl = bundle.getString(VideoPersistence.VIDEO_URL);
	    this.initPlayer();

//        this.videoPersistence.recoverState();
//        Uri videoUri = Uri.parse(this.videoUrl);
//        this.videoView.setVideoURI(videoUri);
    }
    
    private void initPlayer() {
	    this.progressBar.setVisibility(View.VISIBLE);
	    	    
	    // 1. Create a default TrackSelector
		this.mainHandler = new Handler(); // Not currently used, but needed for new MediaSource
		BandwidthMeter bandwidthMeter = new DefaultBandwidthMeter();
		TrackSelection.Factory videoTrackSelectionFactory = 
				new AdaptiveTrackSelection.Factory(bandwidthMeter);
		TrackSelector trackSelector = 
				new DefaultTrackSelector(videoTrackSelectionFactory);
		
		// 2. Create the player
		LoadControl loadControl = new DefaultLoadControl();
		this.player = ExoPlayerFactory.newSimpleInstance(getApplicationContext(), trackSelector, loadControl);
		this.player.setPlayWhenReady(true);
		this.player.addListener(this);
		
		// 3. Create Logger
		this.eventLogger = new EventLogger();
		this.player.setAudioDebugListener(this.eventLogger);
		this.player.setVideoDebugListener(this.eventLogger);
		this.player.setMetadataOutput(this.eventLogger);
				
		// 4. Bind the player to the view
		this.playerView.requestFocus();
		this.playerView.setPlayer(this.player);

		// Measures bandwidth during playback. Can be null if not required.
		DefaultBandwidthMeter bandwidthMeter2 = new DefaultBandwidthMeter();
		
		// Produces DataSource instances through which media data is loaded.
		DataSource.Factory dataSourceFactory = new DefaultDataSourceFactory(this,
			Util.getUserAgent(this, "ShortSands"), bandwidthMeter2);
			
		// This is the MediaSource representing the media to be played.
        Uri videoUri = Uri.parse(this.videoUrl);
		MediaSource videoSource = new HlsMediaSource(videoUri, dataSourceFactory, this.mainHandler, this.eventLogger);

		// Prepare the player with the source.
		long seekTime = 1000000;
		if (seekTime > 0) {
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
	    this.releasePlayer();
//        if (this.videoPlaybackComplete) {
//	    	this.videoPersistence.clearState();
//        } else {
//        	this.videoPersistence.saveState();
//        }
//        this.videoView.stopPlayback();
//        if (this.mediaPlayer != null) {
//        	this.mediaPlayer.release();
//        	this.mediaPlayer = null;
//        }
    }
    
    @Override
    protected void onStop() {
	    super.onStop();
	    Log.d(TAG, "onStop CALLED " + System.currentTimeMillis());
	    //if (Util.SDK_INT > 23) {
		//    this.releasePlayer();
	    //}
    }
    
    private void releasePlayer() {
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
    
    

//	@Override
//    public void onPrepared(MediaPlayer mp) {
//        Log.d(TAG, "onPrepared CALLED " + System.currentTimeMillis());
//        this.mediaPlayer = mp;
//        this.mediaPlayer.setScreenOnWhilePlaying(true);
//        this.mediaPlayer.setOnBufferingUpdateListener(this);
//	    this.videoView.start();
//	    int seekTime = backupSeek();
//	    if (seekTime > 1) {
//	       	this.mediaPlayer.setOnSeekCompleteListener(this);
//	        this.videoView.seekTo(seekTime);
//        } else {
//			this.actualStartVideo();
//        }
//    }
    
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
    
//    public void onSeekComplete(MediaPlayer mp) {
//        Log.d(TAG, "onSeekComplete CALLED " + System.currentTimeMillis());
//        this.actualStartVideo();
//    }
    
//    private void actualStartVideo() {
//	    this.videoView.requestFocus();
//	    this.progressBar.setVisibility(View.GONE);
//    }

//    public void onBufferingUpdate(MediaPlayer mediaPlayer, int percent) {
//	    this.backupPosition = this.getCurrentPosition();
//	    this.backupTime = System.currentTimeMillis();
//        Log.d(TAG, "onBufferingUpdate : " + percent + "%  " + this.backupPosition);
//    }

//    public void onCompletion(MediaPlayer mediaPlayer) {
//        Log.d(TAG, "onCompletion CALLED " + System.currentTimeMillis());
//        this.videoPlaybackComplete = true;
//		this.wrapItUp(Activity.RESULT_OK, null);
//    }

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