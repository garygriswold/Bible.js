package com.shortsands.audioplayer;

/**
 * Created by garygriswold on 8/30/17.
 */
import android.app.ActionBar;
import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.net.Uri;
import android.support.annotation.DrawableRes;
import android.support.annotation.IntDef;
import android.support.annotation.LayoutRes;
import android.support.annotation.Nullable;
import android.support.annotation.StringRes;
import android.support.design.widget.FloatingActionButton;
import android.view.Gravity;
import android.view.MotionEvent;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;
import android.widget.RelativeLayout;
import android.widget.SpinnerAdapter;
import android.widget.TextView;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View.OnClickListener;
import android.view.View.OnHoverListener;
import android.view.View;
import android.view.ViewGroup;
//import android.view.ViewGroup.LayoutParams;
import android.view.Window;
import android.widget.Toolbar;

import java.io.File;

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
    //let scrubSlider: UISlider
    //var progressLink: CADisplayLink?
    // Transient State Variables
    //var scrubSliderDuration: CMTime
    boolean scrubSliderDrag;

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


        // create play, pause, stop
        // create slider
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
        /*
        self.progressLink = CADisplayLink(target: self, selector: #selector(updateProgress))
        self.progressLink!.add(to: .current, forMode: .defaultRunLoopMode)
        self.progressLink!.preferredFramesPerSecond = 15

        self.playButton.addTarget(self, action: #selector(self.play), for: .touchUpInside)
        self.pauseButton.addTarget(self, action: #selector(self.pause), for: .touchUpInside)
        self.stopButton.addTarget(self, action: #selector(self.stop), for: .touchUpInside)
        self.scrubSlider.addTarget(self, action: #selector(scrubSliderChanged), for: .valueChanged)
        self.scrubSlider.addTarget(self, action: #selector(touchDown), for: .touchDown)
        self.scrubSlider.addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
        */
    }

    public void stopPlay() {
        /*
        self.playButton.removeFromSuperview()
        self.pauseButton.removeFromSuperview()
        self.stopButton.removeFromSuperview()
        self.scrubSlider.removeFromSuperview()
        self.progressLink?.invalidate()
        */
    }

    private void updateProgress() {
        /*
        if self.scrubSliderDrag { return }

        if let item = self.audioBible.player?.currentItem {
            if CMTIME_IS_NUMERIC(item.duration) {
                if item.duration != self.scrubSliderDuration {
                    self.scrubSliderDuration = item.duration
                    let duration = CMTimeGetSeconds(item.duration)
                    self.scrubSlider.maximumValue = Float(duration)
                }
            }
            let current = CMTimeGetSeconds(item.currentTime())
            self.scrubSlider.setValue(Float(current), animated: true)
        }
        */
    }

    private void scrubSliderChanged(Object sender, Object event) { // UISlider, UIEvent
        /*
        let slider = self.scrubSlider
        print("scrub slider changed to \(slider.value)")
        if let play = self.audioBible.player {
            if (slider.value < slider.maximumValue) {
                var current: Float
                if let verse = self.audioBible.audioChapter {
                    current = verse.findVerseByPosition(seconds: slider.value)
                } else {
                    current = slider.value
                }
                let time: CMTime = CMTime(seconds: Double(current), preferredTimescale: CMTimeScale(1.0))
                play.seek(to: time)
            } else {
                self.audioBible.advanceToNextItem()
            }
        }
        */
    }

    private void touchDown() {
        Log.d(TAG, "**** touchDown ***");
        this.scrubSliderDrag = true;
    }

    private void touchUpInside() {
        Log.d(TAG, "**** touchUpInside ***");
        this.scrubSliderDrag = false;
    }
}
