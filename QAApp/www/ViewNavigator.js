/**
* This class is the controlling view class for the QAApp.
*
* Transitions:
* Start -> Login (view just appears)
* Start -> Header + Queue (when user is remembered) views just appears)
* Login -> Forgot (use a fading transition)
* Forgot -> Login (use a fading transition)
* Login -> Queue (use a slide to left transition)
* Queue -> Answer (use a slide to left transition)
* Answer -> Queue (use a slide to right transition)
* 
* Navigator Logic
* 0) Listen for transition event
* 1) identify view to be deleted from body
* 2) Make sure the view to be deleted is below new view
* 3) append new view to body
* 3) insure that added view has a higher z-index than to be removed view.
* 4) perform transition
* 5) on completion of transition, remove view
*
* We want to fix HeaderView once it is added, and never delete it.
* We also do not want to include it in the transition.
*/
function ViewNavigator() {
}
ViewNavigator.prototype.start = function() {
	document.body.addEventListener(TRANSITION.EVENT, function(event) {
		var transition = event.detail;
		console.log('found transition', JSON.stringify(transition));
		var fromView = document.getElementById(transition.fromView);
		if (fromView) {
			var newView = document.createElement('div');
			if (newView) {
				newView.id = transition.toView;
				newView.style.height = '100%';
				newView.style.width = '100%';
				newView.style.position = 'absolute';
				newView.innerHTML = viewLibrary[transition.toView];
				document.body.appendChild(newView);
				switch(transition.toView) {
					case 'queueView':
						var viewModel = new QueueViewModel();
						viewModel.display();
				}
				switch(transition.transType) {
					case TRANSITION.SLIDE_LEFT:
						fromView.style.zIndex = 0;
						newView.style.zIndex = 10;
						TweenMax.set(newView, {x: window.outerWidth}); // what is correct location
						TweenMax.to(newView, 1.0, {x: 0, 
							onComplete: finishTransition, onCompleteParams: [fromView]});
						break;
					case TRANSITION.SLIDE_RIGHT:
						fromView.style.zIndex = 10;
						newView.style.zIndex = 0;
						TweenMax.to(fromView, 1.0, {left: window.outerWidth,
							onComplete: finishTransition, onCompleteParams: [fromView]});
						break;
					default:
						finishTransition(fromView);
						break;
				}
			}
		}
	});
	
	function finishTransition(fromView) {
		document.body.removeChild(fromView);
	}
};
