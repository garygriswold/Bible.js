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
import android.widget.ImageView;
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

    private static AudioBibleView instance = null;
    static AudioBibleView shared(AudioBibleController controller, AudioBible audioBible) {
        if (AudioBibleView.instance == null) {
            AudioBibleView.instance = new AudioBibleView(controller, audioBible);
        }
        return AudioBibleView.instance;
    }

    private final AudioBibleController controller;
    private final Activity activity;
    private final AudioBible audioBible;
    private final ViewGroup webview;
    private final RelativeLayout audioPanel;
    private final RelativeLayout.LayoutParams playParams;
    private final RelativeLayout.LayoutParams pauseParams;
    private final ImageButton playButton;
    private final ImageButton pauseButton;
    private final ImageButton stopButton;
    private final SeekBar scrubSlider;
    private final ImageView verseButton;
    private final TextView verseLabel;
    // Precomputed for positionVersePopup
    private Float sliderRange;
    private Float sliderOrigin;
    private Float sliderOriginActual;
    // Transient State Variables
    private MonitorSeekBar monitorSeekBar = null;
    private boolean scrubSliderDrag = false;
    private int verseNum = 0;
    private boolean isAudioViewActive = false;

    private AudioBibleView(AudioBibleController controller, AudioBible audioBible) {
        this.controller = controller;
        this.activity = controller.activity;
        this.audioBible = audioBible;

        Window window = this.activity.getWindow();
        this.webview = (ViewGroup)window.getDecorView();
        //this.webview.setBackgroundColor(0x440000FF); // for debug only

        DisplayMetrics metrics = new DisplayMetrics();
        this.activity.getWindowManager().getDefaultDisplay().getMetrics(metrics);
        Log.d(TAG, "metrics=" + metrics.toString());

        // Compute Dimensions: buttons 3/8 inches,
        int btnDiameter = Math.round(metrics.densityDpi * 3.1f / 8.0f);
        int btnRadius = btnDiameter / 2;
        int panelHeight = (int)(btnDiameter * 3.0);
        int buttonTop = panelHeight - (int)(btnDiameter * 1.2);
        int scrubSliderTop = buttonTop - (int)(btnDiameter * 1.05);

        RelativeLayout layout = new RelativeLayout(this.activity);
        layout.setBackgroundColor(0xFFFFFFFF);
        RelativeLayout.LayoutParams layoutParams =
                new RelativeLayout.LayoutParams((int)(metrics.widthPixels * 0.96), panelHeight);
        layoutParams.leftMargin = (int)(metrics.widthPixels * 0.02);
        layoutParams.topMargin = metrics.heightPixels - (int)(panelHeight * 1.05);
        layout.setLayoutParams(layoutParams);
        this.audioPanel = layout;

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
        this.playParams = new RelativeLayout.LayoutParams(btnDiameter, btnDiameter);
        this.playParams.leftMargin = (metrics.widthPixels / 3) - btnRadius;
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
        this.pauseParams = new RelativeLayout.LayoutParams(btnDiameter, btnDiameter);
        this.pauseParams.leftMargin = (metrics.widthPixels / 3) - btnRadius;
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
        RelativeLayout.LayoutParams stopParams = new RelativeLayout.LayoutParams(btnDiameter, btnDiameter);
        stopParams.leftMargin = (metrics.widthPixels * 2 / 3) - btnRadius;
        stopParams.topMargin = buttonTop;
        layout.addView(stopBtn, stopParams);
        this.stopButton = stopBtn;

        final SeekBar scrub = new SeekBar(this.activity);
        final Resources resources = this.controller.activity.getResources();
        scrub.setThumb(resources.getDrawable(R.drawable.thumb_up));
        scrub.setPadding(btnRadius, 0, btnRadius, 0);
        RelativeLayout.LayoutParams seekParams = new RelativeLayout.LayoutParams(metrics.widthPixels * 4 / 5, btnDiameter);
        seekParams.leftMargin = metrics.widthPixels / 10;
        seekParams.topMargin = scrubSliderTop;
        layout.addView(scrub, seekParams);
        this.scrubSlider = scrub;

        final ImageView verseBtn = new ImageView(this.activity);
        verseBtn.setImageResource(R.drawable.verse_button_32);
        verseBtn.setBackgroundColor(Color.TRANSPARENT);
        RelativeLayout.LayoutParams verseBtnParams = new RelativeLayout.LayoutParams(128, 128);
        verseBtnParams.leftMargin = seekParams.leftMargin + seekParams.height / 2 - verseBtnParams.width / 2;
        verseBtnParams.topMargin = seekParams.topMargin - verseBtnParams.height - 2;
        layout.addView(verseBtn, verseBtnParams);
        this.verseButton = verseBtn;

        TextView verse = new TextView(this.activity);
        verse.setSingleLine(true);
        verse.setText("1");
        verse.setTypeface(Typeface.SANS_SERIF);
        verse.setTextSize(12); // this is measured in pixels 12pt in ios
        verse.setGravity(Gravity.CENTER);

        RelativeLayout.LayoutParams verseParams = new RelativeLayout.LayoutParams(btnRadius, btnRadius);
        verseParams.leftMargin = seekParams.leftMargin + seekParams.height / 2 - verseParams.width / 2;
        verseParams.topMargin = seekParams.topMargin - verseParams.height - 10;
        layout.addView(verse, verseParams);
        this.verseLabel = verse;


        // Precompute Values for positionVersePopup()
        this.sliderRange = 0.0f + seekParams.width - seekParams.height;
        this.sliderOrigin = 0.0f;
        this.sliderOriginActual = 0.0f + seekParams.leftMargin + (seekParams.height - verseBtnParams.width) / 2.0f;
    }

    boolean audioBibleActive() {
        return this.isAudioViewActive;
    }

    void play() {
        this.audioBible.play();
        if (this.isAudioViewActive) {
            this.audioPanel.removeView(this.playButton);
            this.audioPanel.addView(this.pauseButton, this.pauseParams);
        }
    }

    void pause() {
        this.audioBible.pause();
        if (this.isAudioViewActive) {
            this.audioPanel.removeView(this.pauseButton);
            this.audioPanel.addView(this.playButton, this.playParams);
        }
    }

    void stop() {
        this.audioBible.stop();
    }

    /**
     * Start the animation of the seek bar and the use of it to control audio position.
     * @param player
     */
    void startPlay(final MediaPlayer player) {
        if (!this.isAudioViewActive) {
            this.isAudioViewActive = true;
            this.webview.addView(this.audioPanel);
        }
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
                    if (value < seekBar.getMax()) {
                        long position;
                        AudioReference curr = audioBible.getCurrReference();
                        if (curr.audioChapter != null) {
                            verseNum = curr.audioChapter.findVerseByPosition(verseNum, value);
                            position = curr.audioChapter.findPositionOfVerse(verseNum);
                            verseLabel.setText(String.valueOf(verseNum));
                            float xPosition = sliderOriginActual + positionVersePopup();
                            verseButton.setX(xPosition);
                            verseLabel.setX(xPosition);
                        } else {
                            position = value;
                        }
                        player.seekTo((int)position);
                    } else {
                        audioBible.advanceToNextItem();
                        Log.d(TAG, "******** Progress moved to end " + System.currentTimeMillis());
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

    void stopPlay() {
        if (this.audioBibleActive()) {
            this.isAudioViewActive = false;
            this.webview.removeView(this.audioPanel);
        }
        if (this.monitorSeekBar != null) {
            this.monitorSeekBar.isPlaying = false;
            this.monitorSeekBar = null;
        }
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
                        verseButton.animate().translationX(message.arg2).setDuration(80L).start();
                        verseLabel.animate().translationX(message.arg2).setDuration(80L).start();
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
                        if (progressMS == 0) {
                            verseNum = 0;
                        }
                        AudioTOCChapter verse = audioBible.getCurrReference().audioChapter;
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
}
