package com.shortsands.audioplayer;

/**
 * Created by garygriswold on 8/30/17.
 */
import android.annotation.TargetApi;
import android.app.Activity;
import android.content.res.Resources;
import android.graphics.Color;
import android.graphics.drawable.shapes.RoundRectShape;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.Typeface;
import android.media.MediaPlayer;
import android.os.Build.VERSION;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.webkit.ValueCallback;
import android.webkit.WebView;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.util.DisplayMetrics;
import android.util.Log;

//import com.shortsands.yourbible.R; // Remove comment in SafeBible App

class AudioBibleView {

    private static final String TAG = "AudioBibleView";

    private static AudioBibleView instance = null;
    static AudioBibleView shared(Activity activity, AudioBible audioBible) {
        if (AudioBibleView.instance == null) {
            AudioBibleView.instance = new AudioBibleView(activity, audioBible);
        }
        return AudioBibleView.instance;
    }

    @TargetApi(19)
    public static void evaluateJavascript(final String msg, final ValueCallback<String> completed) {
        if (VERSION.SDK_INT >= 19) {
            if (AudioBibleView.instance != null && AudioBibleView.instance.webView != null) {
                AudioBibleView.instance.activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        AudioBibleView.instance.webView.evaluateJavascript(msg, completed);
                    }
                });
            }
        }
    }

    private final Activity activity;
    private final AudioBible audioBible;
    private final ViewGroup rootView;
    private final FrameLayout audioPanel;
    private final int panelHeight;
    private final ImageButton playButton;
    private final ImageButton pauseButton;
    private final ImageButton stopButton;
    private final SeekBar scrubSlider;
    private final RelativeLayout verseButton;
    private final TextView verseLabel;
    private WebView webView;
    // Precomputed for positionVersePopup
    private Float sliderRange;
    private Float sliderOrigin;
    private Float sliderOriginActual;
    // Transient State Variables
    private MonitorSeekBar monitorSeekBar = null;
    private boolean scrubSliderDrag = false;
    private boolean scrubSuspendedPlay = false;
    private int versePriorX = 0;
    private int verseNum = 0;
    private boolean isAudioViewActive = false;

    private AudioBibleView(Activity activity, AudioBible audioBible) {
        this.activity = activity;
        this.audioBible = audioBible;

        Window window = this.activity.getWindow();
        this.rootView = (ViewGroup)window.getDecorView();

        DisplayMetrics metrics = new DisplayMetrics();
        this.activity.getWindowManager().getDefaultDisplay().getMetrics(metrics);
        Log.d(TAG, "metrics=" + metrics.toString());

        // Compute Dimensions: buttons 3/8 inches,
        int btnDiameter = Math.round(metrics.densityDpi * 3.1f / 8.0f);
        int btnRadius = btnDiameter / 2;
        this.panelHeight = (int)(btnDiameter * 3.0);
        int buttonTop = panelHeight - (int)(btnDiameter * 1.2);
        int scrubSliderTop = buttonTop - (int)(btnDiameter * 1.05);

        float radius = btnDiameter / 3.0f;
        float[] radii = new float[] { radius, radius, radius, radius, radius, radius, radius, radius };
        RoundRectShape roundRect = new RoundRectShape(radii, null, null);
        ShapeDrawable background = new ShapeDrawable(roundRect);
        background.getPaint().setColor(0xF3FFFFFF);

        FrameLayout layout = new FrameLayout(this.activity);
        layout.setBackground(background);
        layout.setVisibility(View.INVISIBLE);
        FrameLayout.LayoutParams layoutParams =
                new FrameLayout.LayoutParams((int)(metrics.widthPixels * 0.96), this.panelHeight);
        layoutParams.leftMargin = (int)(metrics.widthPixels * 0.02);
        layoutParams.topMargin = metrics.heightPixels + (int)(panelHeight * 0.2f);
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
        FrameLayout.LayoutParams playPauseParams = new FrameLayout.LayoutParams(btnDiameter, btnDiameter);
        playPauseParams.leftMargin = (metrics.widthPixels / 3) - btnRadius;
        playPauseParams.topMargin = buttonTop;
        playBtn.setLayoutParams(playPauseParams);
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
        pauseBtn.setLayoutParams(playPauseParams);
        layout.addView(pauseBtn);
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
        FrameLayout.LayoutParams stopParams = new FrameLayout.LayoutParams(btnDiameter, btnDiameter);
        stopParams.leftMargin = (metrics.widthPixels * 2 / 3) - btnRadius;
        stopParams.topMargin = buttonTop;
        stopBtn.setLayoutParams(stopParams);
        layout.addView(stopBtn);
        this.stopButton = stopBtn;

        final SeekBar scrub = new SeekBar(this.activity);
        final Resources resources = this.activity.getResources();
        scrub.setThumb(resources.getDrawable(R.drawable.thumb_up));
        scrub.setPadding(btnRadius, 0, btnRadius, 0);
        scrub.setProgressDrawable(resources.getDrawable(R.drawable.audio_progress2));
        FrameLayout.LayoutParams seekParams = new FrameLayout.LayoutParams(metrics.widthPixels * 4 / 5, btnDiameter);
        seekParams.leftMargin = metrics.widthPixels / 10;
        seekParams.topMargin = scrubSliderTop;
        scrub.setLayoutParams(seekParams);
        layout.addView(scrub);
        this.scrubSlider = scrub;

        RelativeLayout verseLayout = new RelativeLayout(this.activity);
        RelativeLayout.LayoutParams verseParams = new RelativeLayout.LayoutParams(btnRadius, btnRadius);
        verseParams.leftMargin = seekParams.leftMargin + seekParams.height / 2 - verseParams.width / 2;
        verseParams.topMargin = seekParams.topMargin - verseParams.height - 2;
        verseLayout.setLayoutParams(verseParams);
        layout.addView(verseLayout);
        this.verseButton = verseLayout;

        final ImageView verseBtn = new ImageView(this.activity);
        verseBtn.setImageResource(R.drawable.verse_button_32);
        verseBtn.setBackgroundColor(Color.TRANSPARENT);
        RelativeLayout.LayoutParams verseBtnParams = new RelativeLayout.LayoutParams(btnRadius, btnRadius);
        verseBtnParams.addRule(RelativeLayout.CENTER_IN_PARENT);
        verseBtn.setLayoutParams(verseBtnParams);
        verseLayout.addView(verseBtn);

        TextView verse = new TextView(this.activity);
        verse.setSingleLine(true);
        verse.setText("1");
        verse.setTypeface(Typeface.SANS_SERIF);
        verse.setTextSize(12); // this is measured in pixels 12pt in ios
        verse.setTextColor(0xFF555555);
        verse.setGravity(Gravity.CENTER);
        RelativeLayout.LayoutParams verseTextParams = new RelativeLayout.LayoutParams(btnRadius, btnRadius);
        verseTextParams.addRule(RelativeLayout.CENTER_IN_PARENT);
        verse.setLayoutParams(verseTextParams);
        verseLayout.addView(verse);
        this.verseLabel = verse;

        // Precompute Values for positionVersePopup()
        this.sliderRange = 0.0f + seekParams.width - seekParams.height;
        this.sliderOrigin = 0.0f;
        this.sliderOriginActual = 0.0f + seekParams.leftMargin + (seekParams.height - verseBtnParams.width) / 2.0f;
    }

    void setWebView(WebView webview) {
        this.webView = webview;
    }

    boolean audioBibleActive() {
        return this.isAudioViewActive;
    }

    void play() {
        this.audioBible.play();
        if (this.isAudioViewActive) {
            this.activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    audioPanel.removeView(playButton);
                    audioPanel.addView(pauseButton);
                }
            });
        }
    }

    void pause() {
        this.audioBible.pause();
        if (this.isAudioViewActive) {
            this.activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    audioPanel.removeView(pauseButton);
                    audioPanel.addView(playButton);
                }
            });
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
            this.activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    isAudioViewActive = true;
                    if (audioPanel.getParent() == null) {
                        rootView.addView(audioPanel);
                        audioPanel.setVisibility(View.VISIBLE);
                        audioPanel.animate().translationYBy(panelHeight * -1.2f).setDuration(1000);
                    } else {
                        audioPanel.animate().translationYBy(panelHeight * -1.3f).setDuration(1000);
                    }
                }
            });
        }
        this.startNewPlayer(player);

        this.scrubSlider.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int value, boolean isUser) {
                MediaPlayer currPlayer = audioBible.getPlayer();
                if (isUser && currPlayer != null) {
                    if (value < seekBar.getMax()) {
                        long position;
                        AudioReference curr = audioBible.getCurrReference();
                        if (curr.audioChapter != null) {
                            int newVerseNum = curr.audioChapter.findVerseByPosition(verseNum, value);
                            position = curr.audioChapter.findPositionOfVerse(newVerseNum);
                            verseLabel.setText(String.valueOf(newVerseNum));
                            float xPosition = sliderOriginActual + positionVersePopup();
                            verseButton.setX(xPosition);
                        } else {
                            position = value;
                        }
                        currPlayer.seekTo((int)position);
                    } else {
                        audioBible.nextChapter();
                        Log.d(TAG, "******** Progress moved to end " + System.currentTimeMillis());
                    }
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                Log.d(TAG, "**** touchDown ***");
                final Resources resources = activity.getResources();
                seekBar.setThumb(resources.getDrawable(R.drawable.thumb_dn));
                scrubSliderDrag = true;
                if (audioBible.isPlaying()) {
                    audioBible.getPlayer().pause();
                    scrubSuspendedPlay = true;
                }
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                Log.d(TAG, "**** touchUpInside ***");
                final Resources resources = activity.getResources();
                seekBar.setThumb(resources.getDrawable(R.drawable.thumb_up));
                scrubSliderDrag = false;
                if (scrubSuspendedPlay) {
                    if (audioBible.getPlayer() != null) {
                        audioBible.getPlayer().start();
                        AudioReference ref = audioBible.getCurrReference();
                        if (ref != null) {
                            AudioControlCenter.shared.updateTextPosition(ref.getNodeId(verseNum));
                        }
                    }
                    scrubSuspendedPlay = false;
                }
            }
        });
    }

    /**
     * This method should be called each time a MediaPlayer is changed.  It is called
     * internally, and by AudioBibleController.
     */
    void startNewPlayer(MediaPlayer player) {
        if (this.monitorSeekBar != null) {
            this.monitorSeekBar.isPlaying = false;
            this.monitorSeekBar = null;
        }
        this.monitorSeekBar = new MonitorSeekBar(player);
        new Thread(this.monitorSeekBar).start();
    }

    void stopPlay() {
        if (this.audioBibleActive()) {
            this.activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    isAudioViewActive = false;
                    audioPanel.animate().translationYBy(panelHeight * 1.3f).setDuration(1000);
                }
            });
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
                    switch(message.what) {
                        case 98:
                            verseButton.animate().translationX(message.arg1).setDuration(80L).start();
                            break;
                        case 99:
                            verseButton.animate().translationX(message.arg1).setDuration(80L).start();
                            verseLabel.setText(String.valueOf(message.arg2));
                            AudioControlCenter.shared.updateTextPosition((String)message.obj);
                            break;
                        default:
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

                    AudioReference reference = audioBible.getCurrReference();
                    if (reference.audioChapter != null) {
                        if (progressMS == 0) {
                            verseNum = 0;
                        }
                        int verseXPos = positionVersePopup();
                        AudioTOCChapter verse = reference.audioChapter;
                        int newVerseNum = verse.findVerseByPosition(verseNum, progressMS);
                        if (newVerseNum != verseNum) {
                            versePriorX = verseXPos;
                            verseNum = newVerseNum;
                            String nodeId = reference.getNodeId(newVerseNum);
                            Message message = this.handler.obtainMessage(99, verseXPos, newVerseNum, nodeId);
                            message.sendToTarget();
                            verseButton.setAlpha(1);
                        } else if (verseXPos != versePriorX) {
                            versePriorX = verseXPos;
                            Message message = this.handler.obtainMessage(98, verseXPos, newVerseNum);
                            message.sendToTarget();
                        }
                    } else {
                        verseButton.setAlpha(0);
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
