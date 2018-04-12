package com.shortsands.aws;

/**
 * Created by garygriswold on 4/11/18.
 * https://stackoverflow.com/questions/27213381/how-to-create-circular-progressbar-in-android
 *
 * When the parent view layout is the 4th parameter in the AwsS3.downloadZipFile
 * That is used as a signal to add a progress view
 */
import android.app.Activity;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.RelativeLayout;
import android.widget.ProgressBar;

public class ProgressCircle extends ProgressBar {

        //let circlePathLayer = CAShapeLayer()
        //let circleRadius: CGFloat = 20.0
        private ViewGroup parentView;

        public ProgressCircle(Activity activity) {
            super(activity);
            RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(300, 20);
            params.leftMargin = 50;
            params.topMargin = 100;
            this.setLayoutParams(params);

            Window window = activity.getWindow();
            this.parentView = (ViewGroup) window.getDecorView();
            this.parentView.addView(this);
        }

        void remove() {
            this.parentView.removeView(this);
        }
/*
        void addToParentAndCenter(view: UIView) {
            view.addSubview(self)
            view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[v]|", options: .init(rawValue: 0),
            metrics: nil, views: ["v": self]))
            view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[v]|", options: .init(rawValue: 0),
            metrics: nil, views:  ["v": self]))
            self.translatesAutoresizingMaskIntoConstraints = false
        }

        void setProgress(int current, int max) {
            super.setMax(max);
            super.setProgress(current);
        }

        var progress: CGFloat {
            get {
                return circlePathLayer.strokeEnd
            }
            set {
                if newValue > 1 {
                    circlePathLayer.strokeEnd = 1
                } else if newValue < 0 {
                    circlePathLayer.strokeEnd = 0
                } else {
                    circlePathLayer.strokeEnd = newValue
                }
            }
        }

        void remove() {
            UIView.animate(withDuration: 0.7, delay: 0.3,
            options: UIViewAnimationOptions.curveLinear,
            animations: { self.layer.opacity = 0 },
            completion: { (finished) in self.removeFromSuperview() }
            )
        }

        CGRect circleFrame() {
            var circleFrame = CGRect(x: 0, y: 0, width: 2 * circleRadius, height: 2 * circleRadius)
            let circlePathBounds = circlePathLayer.bounds
            circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
            circleFrame.origin.y = circlePathBounds.midY - circleFrame.midY
            return circleFrame
        }

        UIBezierPath circlePath() {
            return UIBezierPath(ovalIn: circleFrame())
        }

        public override void layoutSubviews() {
            super.layoutSubviews()
            circlePathLayer.frame = bounds
            circlePathLayer.path = circlePath().cgPath
        }
        */
}

