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

class AudioBibleView {

    private static final String TAG = "AudioBibleView";
    private static final int TOP_BAR_HEIGHT = 100;

    private final AudioBibleController controller;
    private final Activity activity;
    private final AudioBible audioBible;
    private final RelativeLayout layout;
    private final RelativeLayout.LayoutParams playParams;
    private final RelativeLayout.LayoutParams pauseParams;
    private final ImageButton playButton;
    private final ImageButton pauseButton;
    private final ImageButton stopButton;
    private final SeekBar seekBar;
    // Transient State Variables
    private MonitorSeekBar monitorSeekBar = null;
    //var scrubSliderDuration: CMTime
    //boolean scrubSliderDrag;

    AudioBibleView(AudioBibleController controller, AudioBible audioBible) {
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

    void play() {
        this.audioBible.play();
        this.layout.removeView(this.playButton);
        this.layout.addView(this.pauseButton, this.pauseParams);
    }

    void pause() {
        this.audioBible.pause();
        this.layout.removeView(this.pauseButton);
        this.layout.addView(this.playButton, this.playParams);
    }

    void stop() {
        this.audioBible.stop();
    }

    /**
     * Start the animation of the seek bar and the use of it to control audio position.
     * @param player
     */
    void startPlay(final MediaPlayer player) {
        if (this.monitorSeekBar != null) {
            this.monitorSeekBar.isPlaying = false;
            this.monitorSeekBar = null;
        }
        this.monitorSeekBar = new MonitorSeekBar(player);
        new Thread(this.monitorSeekBar).start();

        this.seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int value, boolean isUser) {
                if (isUser && player != null) {
                    if (value < seekBar.getMax()) {
                        int current;
                        Reference curr = audioBible.getCurrReference();
                        if (curr.audioChapter != null) {
                            current = (int)curr.audioChapter.findVerseByPosition(value / 1000);
                        } else {
                            current = value / 1000;
                        }
                        Log.d(TAG, "***** Backup Verse: " + value + "  " + current);
                        player.seekTo(current * 1000);
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

    class MonitorSeekBar implements Runnable {
        private MediaPlayer player;
        public boolean isPlaying;

        MonitorSeekBar(MediaPlayer player) {
            this.player = player;
            this.isPlaying = true;
        }
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
            Thread.interrupted();
        }
    }

    void stopPlay() {
        // We reach this on clicking
        // But we need to reach this on completing all files.
        if (this.monitorSeekBar != null) {
            this.monitorSeekBar.isPlaying = false;
            this.monitorSeekBar = null;
        }
        /*
        self.playButton.removeFromSuperview()
        self.pauseButton.removeFromSuperview()
        self.stopButton.removeFromSuperview()
        self.scrubSlider.removeFromSuperview()
        self.progressLink?.invalidate()
        */
    }
}
