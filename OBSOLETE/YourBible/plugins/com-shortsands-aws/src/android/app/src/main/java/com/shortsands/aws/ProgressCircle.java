package com.shortsands.aws;

/**
 * Created by garygriswold on 4/11/18.
 * https://stackoverflow.com/questions/27213381/how-to-create-circular-progressbar-in-android
 *
 * https://demonuts.com/circular-progress-bar-kotlin/
 *
 * When the parent view layout is the 4th parameter in the AwsS3.downloadZipFile
 * That is used as a signal to add a progress view
 */
import android.animation.Animator;
import android.app.Activity;
import android.app.ProgressDialog;
import android.os.Build.VERSION;
import android.R.style;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.ViewGroup;
import android.view.ViewPropertyAnimator;
import android.view.Window;
import android.widget.RelativeLayout;
import android.widget.ProgressBar;

public class ProgressCircle extends ProgressBar {

        private static String TAG = "ProgressCircle";

        private Activity activity;
        private ViewGroup parentView;

        public ProgressCircle(Activity activity) {
            super(activity);
            this.activity = activity;
            //this.setIndeterminate(false);

            Window window = activity.getWindow();
            this.parentView = (ViewGroup)window.getDecorView();

            DisplayMetrics metrics = new DisplayMetrics();
            activity.getWindowManager().getDefaultDisplay().getMetrics(metrics);
            Log.d(TAG, "metrics=" + metrics.toString());
            int diameter = metrics.widthPixels / 6;

            RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(diameter, diameter);
            params.leftMargin = (metrics.widthPixels - diameter) / 2;
            params.topMargin = (metrics.heightPixels - diameter) / 2;
            this.setLayoutParams(params);

            final ProgressCircle progBar = this;
            this.activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    parentView.addView(progBar);
                }
            });

        }

        void setProgress(final long bytesCurrent, final long bytesTotal) {
            this.activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    int total = (bytesTotal < (long)Integer.MAX_VALUE) ? (int)bytesTotal : (int)(bytesTotal / 1000L);
                    setMax(total);
                    int current = (bytesCurrent < (long)Integer.MAX_VALUE) ? (int)bytesCurrent : (int)(bytesCurrent / 1000L);
                    if (VERSION.SDK_INT >= 24) {
                        setProgress(current, true);
                    } else {
                        setProgress(current);
                    }
                }
            });
        }

        void remove() {
            final ProgressCircle progBar = this;
            this.activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    ViewPropertyAnimator animate = animate().alpha(0).setDuration(1000);
                    animate.setListener(new Animator.AnimatorListener() {
                        @Override
                        public void onAnimationEnd(Animator animation) {
                            parentView.removeView(progBar);
                        }
                        @Override
                        public void onAnimationCancel(Animator animation) {
                            parentView.removeView(progBar);
                        }
                        @Override
                        public void onAnimationStart(Animator animation) {}
                        @Override
                        public void onAnimationRepeat(Animator animation) {}
                    });
                }
            });
        }
}



