package com.shortsands.audioplayer;

/**
 * Created by garygriswold on 8/30/17.
 */
import android.app.Activity;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.view.MotionEvent;
import android.widget.ImageButton;
import android.widget.LinearLayout.LayoutParams;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;

public class AudioBibleView {

    private static String TAG = "AudioBibleView";
    private static int TOP_BAR_HEIGHT = 100;

    AudioBibleController controller;
    Activity activity;
    AudioBible audioBible;
    private RelativeLayout layout;
    private RelativeLayout.LayoutParams playParams;
    private RelativeLayout.LayoutParams pauseParams;
    private ImageButton playButton;
    private ImageButton pauseButton;
    private ImageButton stopButton;
    private SeekBar seekBar;
    // Transient State Variables
    //var scrubSliderDuration: CMTime
    //boolean scrubSliderDrag;
    boolean isPlaying = false;

    public AudioBibleView(AudioBibleController controller, AudioBible audioBible) { // view is UIView equiv
        this.controller = controller;
        this.activity = controller.activity;
        this.audioBible = audioBible;

        Window window = this.activity.getWindow();
        ViewGroup view = (ViewGroup)window.getDecorView();

        RelativeLayout layout = new RelativeLayout(this.activity);
        layout.setLayoutParams(new RelativeLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
        view.addView(layout);
        this.layout = layout;

        DisplayMetrics metrics = new DisplayMetrics();
        this.activity.getWindowManager().getDefaultDisplay().getMetrics(metrics);
        int buttonTop = metrics.heightPixels / 10 + TOP_BAR_HEIGHT;

        final ImageButton play = new ImageButton(this.activity);
        play.setImageResource(R.drawable.play_up_button);
        play.setBackgroundColor(Color.TRANSPARENT);
        play.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent event) {
                switch(event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        play.setImageResource(R.drawable.play_dn_button);
                        break;
                    case MotionEvent.ACTION_UP:
                        play.setImageResource(R.drawable.play_up_button);
                        play();
                        break;
                }
                return false;
            }
        });
        this.playParams = new RelativeLayout.LayoutParams(84, 84);
        this.playParams.leftMargin = (metrics.widthPixels / 3) - 44;
        this.playParams.topMargin = buttonTop;
        this.playButton = play;

        final ImageButton pause = new ImageButton(this.activity);
        pause.setImageResource(R.drawable.pause_up_button);
        pause.setBackgroundColor(Color.TRANSPARENT);
        pause.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent event) {
                switch(event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        pause.setImageResource(R.drawable.pause_dn_button);
                        break;
                    case MotionEvent.ACTION_UP:
                        pause.setImageResource(R.drawable.pause_up_button);
                        pause();
                        break;
                }
                return false;
            }
        });
        this.pauseParams = new RelativeLayout.LayoutParams(84, 84);
        this.pauseParams.leftMargin = (metrics.widthPixels / 3) - 44;
        this.pauseParams.topMargin = buttonTop;
        layout.addView(pause, this.pauseParams);
        this.pauseButton = pause;

        final ImageButton stop = new ImageButton(this.activity);
        stop.setImageResource(R.drawable.stop_up_button);
        stop.setBackgroundColor(Color.TRANSPARENT);
        stop.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent event) {
                switch(event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        stop.setImageResource(R.drawable.stop_dn_button);
                        break;
                    case MotionEvent.ACTION_UP:
                        stop.setImageResource(R.drawable.stop_up_button);
                        stop();
                        break;
                }
                return false;
            }
        });
        RelativeLayout.LayoutParams stopParams = new RelativeLayout.LayoutParams(84, 84);
        stopParams.leftMargin = (metrics.widthPixels * 2 / 3) - 44;
        stopParams.topMargin = buttonTop;
        layout.addView(stop, stopParams);
        this.stopButton = stop;

        this.seekBar = new SeekBar(this.activity);
        RelativeLayout.LayoutParams seekParams = new RelativeLayout.LayoutParams(metrics.widthPixels * 4 / 5, 84);
        seekParams.leftMargin = metrics.widthPixels / 10;
        seekParams.topMargin = buttonTop + 200;
        layout.addView(this.seekBar, seekParams);
    }

    public void play() {
        this.audioBible.play();
        this.layout.removeView(this.playButton);
        this.layout.addView(this.pauseButton, this.pauseParams);
    }

    public void pause() {
        this.audioBible.pause();
        this.layout.removeView(this.pauseButton);
        this.layout.addView(this.playButton, this.playParams);
    }

    public void stop() {
        this.audioBible.updateMediaPlayStateTime();
        this.audioBible.sendAudioAnalytics();
        this.audioBible.stop();
    }

    public void startPlay() {
        this.isPlaying = true;
        final MediaPlayer player = this.audioBible.mediaPlayer;

        new Thread(new Runnable() {
            public void run() {
                while(player != null && isPlaying) {
                    seekBar.setMax(player.getDuration());
                    seekBar.setProgress(player.getCurrentPosition());
                    try {
                        Thread.sleep(200);
                    } catch(InterruptedException ex) {
                        Log.d(TAG, "Sleep Interrupted Exception");
                    }
                }
            }
        }).start();

        this.seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int value, boolean isUser) {
                Log.d(TAG, "progress changed");
                if (isUser) {
                    if (player != null) {
                        if (value < seekBar.getMax()) {
                            //var current: Float
                            //if let verse = self.audioBible.audioChapter {
                            //    current = verse.findVerseByPosition(seconds: slider.value)
                            //} else {
                            //    current = slider.value
                            //}
                            //let time: CMTime = CMTime(seconds: Double(current), preferredTimescale: CMTimeScale(1.0)
                            player.seekTo(value);
                        } else {
                            audioBible.advanceToNextItem();
                        }
                    }
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                Log.d(TAG, "**** touchDown ***");
                //scrubSliderDrag = true;
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                Log.d(TAG, "**** touchUpInside ***");
                //scrubSliderDrag = false;
            }
        });
    }

    public void stopPlay() {
        // We reach this on clicking
        // But we need to reach this on completing a file.
        this.isPlaying = false;
        /*
        self.playButton.removeFromSuperview()
        self.pauseButton.removeFromSuperview()
        self.stopButton.removeFromSuperview()
        self.scrubSlider.removeFromSuperview()
        self.progressLink?.invalidate()
        */
    }
}
