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
 * Created by garygriswold on 1/26/17.
 * This is based up the following plugin:
 * https://github.com/nchutchind/cordova-plugin-streaming-media
 */
public class VideoActivity extends Activity implements OnClickListener {//, 
		//	ExoPlayer.EventListener, PlaybackControlView.VisibilityListener {
		//ChunkSampleSource.EventListener,
		//HlsSampleSource.EventListener,
		//DefaultBandwidthMeter.EventListener,
		//MediaCodecVideoTrackRenderer.EventListener,
		//MediaCodecAudioTrackRenderer.EventListener {
    private final static String TAG = "VideoActivity";
//    private VideoPersistence videoPersistence = new VideoPersistence(this);
//    private VideoView videoView;
//    private MediaController mediaController;
//    private MediaPlayer mediaPlayer;
    private ProgressBar progressBar;
	private Handler mainHandler;
	private SimpleExoPlayer player;
	private SimpleExoPlayerView playerView;
	private EventLogger eventLogger;
    //private ExoPlayer player;
    //private PlayerControl playerControl;
    private String videoId;
    private String videoUrl;
//    private int currentPosition = 0;
//    private boolean videoPlaybackComplete = false;
//    private Date timestamp = new Date();
        
    // Error recovery
//    private boolean onErrorRecovery = false;
//    private int backupPosition = 0;
//    private long backupTime = 0L;
//    private long errorTime = 0L;
    
//    public String getVideoId() {
//	    return(this.videoId);
//    }
//    public void setVideoId(String id) {
//	    this.videoId = id;
//    }
//    public String getVideoUrl() {
//	    return(this.videoUrl);
//    }
//    public void setVideoUrl(String url) {
//	    this.videoUrl = url;
//    }
//    public int getCurrentPosition() {
//	    return((this.videoView != null) ? this.videoView.getCurrentPosition() : 0);
//    }
//    public void setCurrentPosition(int pos) {
//	    this.currentPosition = pos;
//    }
//    public void setTimestamp(Date dt) {
//	    this.timestamp = dt;
//    } 

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
        
//        this.videoView.setOnPreparedListener(this);
//        this.videoView.setOnCompletionListener(this);
//        this.videoView.setOnInfoListener(this); //requires SDK 17
//        this.videoView.setOnErrorListener(this);
        
//        this.mediaController = new MediaController(this);
//        this.mediaController.setAnchorView(this.videoView);
//        this.mediaController.setMediaPlayer(this.videoView);
//        this.videoView.setMediaController(this.mediaController);

//		player = ExoPlayer.Factory.newInstance(PlayerConstants.RENDERER_COUNT, MIN_BUFFER_MS, MIN_REBUFFER_MS);

//		playerControl = new PlayerControl(player);
//		player.addListener(this);  /// Must this be repeated for each listener

		this.createPlayer();
		this.preparePlayer();
    }
    
    private void createPlayer() {
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
		
		// 3. Create Logger
		this.eventLogger = new EventLogger();
		this.player.addListener(this.eventLogger);
		this.player.setAudioDebugListener(this.eventLogger);
		this.player.setVideoDebugListener(this.eventLogger);
		this.player.setMetadataOutput(this.eventLogger);
		//this.player.setVideoListener(this.eventLogger);
				
		// 4. Create the view
		//this.playerView = (SimpleExoPlayerView) findViewById(R.id.player_view);
		//this.playerView.setControllerVisibilityListener(this);
		this.playerView.requestFocus();
		
		// Bind the player to the view.
		this.playerView.setPlayer(this.player);
		// there is also a this.player.setVideoSurfaceView(this.playerView);
    }
    
    private void preparePlayer() {
		// Measures bandwidth during playback. Can be null if not required.
		DefaultBandwidthMeter bandwidthMeter = new DefaultBandwidthMeter();
		
		// Produces DataSource instances through which media data is loaded.
		DataSource.Factory dataSourceFactory = new DefaultDataSourceFactory(this,
			Util.getUserAgent(this, "ShortSands"), bandwidthMeter);
			
		// Produces Extractor instances for parsing the media data.
		ExtractorsFactory extractorsFactory = new DefaultExtractorsFactory();
		
		// This is the MediaSource representing the media to be played.
		String mp4VideoUrl = "https://player.vimeo.com/external/157373759.sd.mp4?s=788c497c7c25002898dad7d0f2187cadfb6787e6&profile_id=165";
        Uri mp4VideoUri = Uri.parse(mp4VideoUrl);
		MediaSource videoSource = new ExtractorMediaSource(mp4VideoUri,
				dataSourceFactory, extractorsFactory, null, null);

		// Prepare the player with the source.
		this.player.prepare(videoSource);	    
    }
    
    @Override
    protected void onStart() {
	    super.onStart();
	    Log.d(TAG, "onStart CALLED " + System.currentTimeMillis()); 
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
//        this.videoPersistence.recoverState();
//        Uri videoUri = Uri.parse(this.videoUrl);
//        this.videoView.setVideoURI(videoUri);
    }

	/**
	* Activity docs recommend that this method be used for persistent storage.
	* SharedPreferences is used to save the current location in the current video
	*/
    @Override
    protected void onPause() {
        super.onPause();
        Log.d(TAG, "onPause CALLED " + System.currentTimeMillis());
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
    }
    
    @Override
    protected void onDestroy() {
	    super.onDestroy();
	    Log.d(TAG, "onDestroy CALLED " + System.currentTimeMillis());
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

//    public boolean onError(MediaPlayer mediaPlayer, int what, int extra) {
//	    this.errorTime = System.currentTimeMillis();
//        String message;
//        switch (what) {
//            case MediaPlayer.MEDIA_ERROR_IO:
//                message = "MEDIA ERROR IO";
//                break;
//            case MediaPlayer.MEDIA_ERROR_MALFORMED:
//                message = "MEDIA ERROR MALFORMED";
//                break;
//            case MediaPlayer.MEDIA_ERROR_NOT_VALID_FOR_PROGRESSIVE_PLAYBACK:
//                message = "MEDIA ERROR NOT VALID FOR PROGRESSIVE PLAYBACK";
//                break;
//            case MediaPlayer.MEDIA_ERROR_SERVER_DIED:
//                message = "MEDIA ERROR SERVER DIED";
//                break;
//            case MediaPlayer.MEDIA_ERROR_TIMED_OUT:
//                message = "MEDIA ERROR TIMED OUT";
//                break;
//            case MediaPlayer.MEDIA_ERROR_UNKNOWN:
//                message = "MEDIA ERROR UNKNOWN";
//                break;
//            case MediaPlayer.MEDIA_ERROR_UNSUPPORTED:
//                message = "MEDIA ERROR UNSUPPORTED";
//                break;
//            default:
//                message = "Unknown Error " + what;
//        }
//        Log.e(TAG, "onError " + message + " " + extra);
//
//        mediaPlayer.reset();
//        this.onErrorRecovery = true;
//        this.progressBar.setVisibility(View.VISIBLE);
//        Uri videoUri = Uri.parse(this.videoUrl);
//        this.videoView.setVideoURI(videoUri);
//        
//        return true;
//    }

//    public boolean onInfo(MediaPlayer mediaPlayer, int what, int extra) {
//        String message;
//        switch(what) {
//            case MediaPlayer.MEDIA_INFO_UNKNOWN:
//                message = "MEDIA INFO UNKNOWN";
//                break;
//            case MediaPlayer.MEDIA_INFO_VIDEO_TRACK_LAGGING:
//                message = "MEDIA INFO VIDEO TRACK LAGGING";
//                break;
//            case MediaPlayer.MEDIA_INFO_VIDEO_RENDERING_START:
//                message = "MEDIA INFO VIDEO RENDERING START";
//                break;
//            case MediaPlayer.MEDIA_INFO_BUFFERING_START:
//                message = "MEDIA INFO BUFFERING START";
//                break;
//            case MediaPlayer.MEDIA_INFO_BUFFERING_END:
//                message = "MEDIA INFO BUFFERING END";
//                break;
//            //case MediaPlayer.MEDIA_INFO_NETWORK_BANDWIDTH:
//            //    //(703) - bandwidth information is available (as extra kbps)
//            //    break;
//            case MediaPlayer.MEDIA_INFO_BAD_INTERLEAVING:
//                message = "MEDIA INFO BAD INTERLEAVING";
//                break;
//            case MediaPlayer.MEDIA_INFO_NOT_SEEKABLE:
//                message = "MEDIA INFO NOT SEEKABLE";
//                break;
//            case MediaPlayer.MEDIA_INFO_METADATA_UPDATE:
//                message = "MEDIA INFO METADATA UPDATE";
//                break;
//            case MediaPlayer.MEDIA_INFO_UNSUPPORTED_SUBTITLE:
//                message = "MEDIA INFO UNSUPPORTED SUBTITLE";
//                break;
//            case MediaPlayer.MEDIA_INFO_SUBTITLE_TIMED_OUT:
//                message = "MEDIA INFO SUBTITLE TIMED OUT";
//                break;
//            default:
//                message = "Unknown Info " + what;
//                break;
//        }
//        Log.d(TAG, "onInfo " + message + " " + extra);
//        return(true);
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

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        Log.d(TAG, "onTouchEvent CALLED " + System.currentTimeMillis());
//        if (this.mediaController != null)
//            this.mediaController.show();
        return false;
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
    
    @Override
    public void onClick(View view) {
        Log.d(TAG, "onClick CALLED " + System.currentTimeMillis());
    }
}