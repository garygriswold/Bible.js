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
console.log('loading ViewNavigator starts');
function ViewNavigator() {
	
}
ViewNavigator.prototype.start = function() {
	//var d = document.createElement('div');
	//d.textContent = 'Hello World';
	//document.body.appendChild(d);
	console.log('inside ViewNavigator.start');
	
	document.body.addEventListener(TRANSITION.EVENT, function(event) {
		var transition = event.detail;
		console.log('found transition', JSON.stringify(transition));
		var fromView = document.getElementById(transition.fromView);
		if (fromView) {
			fromView.setAttribute('z-index', 0);
			var newView = document.createElement('div');
			if (newView) {
				newView.setAttribute('id', transition.toView);
				newView.setAttribute('z-index', 1);
				document.body.appendChild(newView);
				newView.innerHTML = viewLibrary[transition.toView];
				switch(transition.transTye) {
					case TRANSITION.SLIDE_LEFT:
						TweenMax.fromTo(newView, 3, {left: 1000}, {left: 0});// what are correct measurements?
						break;
					case TRANSITION.SLIDE_RIGHT:
						TweenMax.fromTo(newView, 3, {left: 0}, {left: 1000})
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
console.log('loading ViewNavigator ends');