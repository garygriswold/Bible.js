package com.shortsands.audioplayer;

/**
 * Created by garygriswold on 8/30/17.
 */
import android.app.Activity;
import android.content.res.Resources;
import android.graphics.Color;
import android.graphics.Typeface;
import android.media.MediaPlayer;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.view.Gravity;
import android.view.MotionEvent;
import android.widget.ImageButton;
import android.widget.LinearLayout.LayoutParams;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;
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
    private final SeekBar scrubSlider;
    private final TextView verseLabel;
    // Precomputed for positionVersePopup
    private Float sliderRange;
    private Float sliderOrigin;
    // Transient State Variables
    private MonitorSeekBar monitorSeekBar = null;
    private boolean scrubSliderDrag = false;
    private int verseNum = 1;
    //private boolean isAudioViewActive = false; DO I need this on android?

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

        final ImageButton playBtn = new ImageButton(this.activity);
        playBtn.setImageResource(R.drawable.play_up_button);
        playBtn.setBackgroundColor(Color.TRANSPARENT);
        playBtn.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent event) {
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        playBtn.setImageResource(R.drawable.play_dn_button);
                        break;
                    case MotionEvent.ACTION_UP:
                        playBtn.setImageResource(R.drawable.play_up_button);
                        play();
                        break;
                }
                return false;
            }
        });
        this.playParams = new RelativeLayout.LayoutParams(84, 84);
        this.playParams.leftMargin = (metrics.widthPixels / 3) - 44;
        this.playParams.topMargin = buttonTop;
        this.playButton = playBtn;

        final ImageButton pauseBtn = new ImageButton(this.activity);
        pauseBtn.setImageResource(R.drawable.pause_up_button);
        pauseBtn.setBackgroundColor(Color.TRANSPARENT);
        pauseBtn.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent event) {
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        pauseBtn.setImageResource(R.drawable.pause_dn_button);
                        break;
                    case MotionEvent.ACTION_UP:
                        pauseBtn.setImageResource(R.drawable.pause_up_button);
                        pause();
                        break;
                }
                return false;
            }
        });
        this.pauseParams = new RelativeLayout.LayoutParams(84, 84);
        this.pauseParams.leftMargin = (metrics.widthPixels / 3) - 44;
        this.pauseParams.topMargin = buttonTop;
        layout.addView(pauseBtn, this.pauseParams);
        this.pauseButton = pauseBtn;

        final ImageButton stopBtn = new ImageButton(this.activity);
        stopBtn.setImageResource(R.drawable.stop_up_button);
        stopBtn.setBackgroundColor(Color.TRANSPARENT);
        stopBtn.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent event) {
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        stopBtn.setImageResource(R.drawable.stop_dn_button);
                        break;
                    case MotionEvent.ACTION_UP:
                        stopBtn.setImageResource(R.drawable.stop_up_button);
                        stop();
                        break;
                }
                return false;
            }
        });
        RelativeLayout.LayoutParams stopParams = new RelativeLayout.LayoutParams(84, 84);
        stopParams.leftMargin = (metrics.widthPixels * 2 / 3) - 44;
        stopParams.topMargin = buttonTop;
        layout.addView(stopBtn, stopParams);
        this.stopButton = stopBtn;

        final SeekBar scrub = new SeekBar(this.activity);
        final Resources resources = this.controller.activity.getResources();
        scrub.setThumb(resources.getDrawable(R.drawable.thumb_up));
        scrub.setPadding(42, 0, 42, 0);
        RelativeLayout.LayoutParams seekParams = new RelativeLayout.LayoutParams(metrics.widthPixels * 4 / 5, 84);
        seekParams.leftMargin = metrics.widthPixels / 10;
        seekParams.topMargin = buttonTop + 200;
        layout.addView(scrub, seekParams);
        this.scrubSlider = scrub;

        TextView verse = new TextView(this.activity);
        verse.setSingleLine(true);
        verse.setText("1");
        verse.setTypeface(Typeface.SANS_SERIF);
        verse.setTextSize(12); // this is measured in pixels 12pt in ios
        verse.setTextColor(0xFF000000);
        verse.setBackgroundColor(0xFFFF0000);
        verse.setGravity(Gravity.CENTER);

   //     verse.setSelected(false);
//        verse.layer.borderColor = UIColor.black.cgColor
//        verse.layer.borderWidth = 1.0
//        verse.layer.cornerRadius = verse.frame.width / 2
        RelativeLayout.LayoutParams verseParams = new RelativeLayout.LayoutParams(32, 32);
        verseParams.leftMargin = seekParams.leftMargin + seekParams.height / 2 - verseParams.width / 2;
        verseParams.topMargin = seekParams.topMargin - verseParams.height - 2;
        layout.addView(verse, verseParams);
        this.verseLabel = verse;

        // Precompute Values for positionVersePopup()
        this.sliderRange = 0.0f + seekParams.width - seekParams.height;
        this.sliderOrigin = 0.0f;

//        play.layer.shadowOpacity = 0.5
//        play.layer.shadowOffset = CGSize(width: 2.0, height: 1.0)
//        pause.layer.shadowOpacity = 0.5
//        pause.layer.shadowOffset = CGSize(width: 2.0, height: 1.0)
//        stop.layer.shadowOpacity = 0.5
//        stop.layer.shadowOffset = CGSize(width: 2.0, height: 1.0)

//        verse.layer.shadowOpacity = 0.5
//        verse.layer.shadowOffset = CGSize(width: 2.0, height: 1.0)
//        verse.layer.masksToBounds = true
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

        this.scrubSlider.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int value, boolean isUser) {
                if (isUser && player != null) {
                    Log.d(TAG, "value max " + value + "  " + seekBar.getMax());
                    if (value < seekBar.getMax()) {
                        //int current;
                        Reference curr = audioBible.getCurrReference();
                        if (curr.audioChapter != null) {

                            //current = (int)curr.audioChapter.findVerseByPosition(value / 1000);
                            verseNum = curr.audioChapter.findVerseByPosition(verseNum, value);
                            //seconds: Double(self.scrubSlider.value))
                            verseLabel.setText(String.valueOf(verseNum));
                            //verseLabel.center = positionVersePopup();
                    //        verseLabel.setX(positionVersePopup());
                        } else {
                            //current = value / 1000;
                            verseNum = value;
                        }
                        Log.d(TAG, "***** Backup Verse: " + value + "  " + verseNum);
                        //player.seekTo(current * 1000);
                        player.seekTo(verseNum);
                    }
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                Log.d(TAG, "**** touchDown ***");
                final Resources resources = controller.activity.getResources();
                seekBar.setThumb(resources.getDrawable(R.drawable.thumb_dn));
                scrubSliderDrag = true;
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                Log.d(TAG, "**** touchUpInside ***");
                final Resources resources = controller.activity.getResources();
                seekBar.setThumb(resources.getDrawable(R.drawable.thumb_up));
                scrubSliderDrag = false;
            }
        });
    }

    class MonitorSeekBar implements Runnable {
        private MediaPlayer player;
        public boolean isPlaying;
        private Handler handler;

        MonitorSeekBar(MediaPlayer player) {
            this.player = player;
            this.isPlaying = true;
            this.handler = new Handler(Looper.getMainLooper()) {
                @Override
                public void handleMessage(Message message) {
                    if (message.what == 99) {
                        verseLabel.setText(String.valueOf(message.arg1));
                        verseLabel.animate().translationX(message.arg2).setDuration(80L).start();
                        Log.d(TAG, "IN UI THREAD verseNum " + verseNum + "  position: " + message.arg2);
                    } else {
                        Log.d(TAG, "Unknown message " + message.what);
                    }
                }
            };
        }

        public void run() {
            while (player != null && isPlaying) {
                if (!scrubSliderDrag) {
                    scrubSlider.setMax(player.getDuration());
                    int progressMS = player.getCurrentPosition();
                    scrubSlider.setProgress(progressMS);

                    if (audioBible.getCurrReference().audioChapter != null) {
                        TOCAudioChapter verse = audioBible.getCurrReference().audioChapter;
                        verseNum = verse.findVerseByPosition(verseNum, progressMS);
                        int verseXPos = positionVersePopup();
                        Message message = this.handler.obtainMessage(99, verseNum, verseXPos);
                        message.sendToTarget();
                    }
                }
                try {
                    Thread.sleep(100);
                } catch (InterruptedException ex) {
                    Log.d(TAG, "Sleep Interrupted Exception");
                }
            }
            Thread.interrupted();
        }
    }

    private int positionVersePopup() {
        Float sliderPct = 1.0f * this.scrubSlider.getProgress() / this.scrubSlider.getMax();
        Float sliderValueToPixels = sliderPct * this.sliderRange + this.sliderOrigin;
        return Math.round(sliderValueToPixels);
    }

    void stopPlay() {
        if (this.monitorSeekBar != null) {
            this.monitorSeekBar.isPlaying = false;
            this.monitorSeekBar = null;
        }
        this.layout.removeView(this.playButton);
        this.layout.removeView(this.pauseButton);
        this.layout.removeView(this.stopButton);
        this.layout.removeView(this.scrubSlider);
        this.layout.removeView(this.verseLabel);

        Window window = this.activity.getWindow();
        ViewGroup view = (ViewGroup)window.getDecorView();
        if (view != null) {
            view.removeView(this.layout);
        }
    }
}
