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
"use strict";
function ViewNavigator() {
	this.currentState = new CurrentState();
	this.httpClient = new HttpClient();
	this.queueModel = new QueueViewModel(this);
	this.answerModel = new AnswerViewModel(this);
	this.rolesModel = new RolesViewModel(this);
}
ViewNavigator.prototype.transition = function(fromViewName, toViewName, transaction, animation, status, results) {
	console.log('Transition', fromViewName, toViewName, transaction, animation);
	var fromView = document.getElementById(fromViewName);
	if (fromView) {
		var newView = document.createElement('div');
		if (newView) {
			newView.id = toViewName;
			newView.style.height = '100%';
			newView.style.width = '100%';
			newView.style.position = 'absolute';
			newView.style.backgroundColor = 'white';
			newView.innerHTML = viewLibrary[toViewName];
			document.body.appendChild(newView);
			switch(toViewName) {
				case 'queueView':
					if (transaction === 'openQuestionCount') {
						this.queueModel.openQuestionCount();
					} else if (transaction === 'returnQuestion') {
						this.queueModel.returnQuestion();
					} else if (transaction === 'sendAnswer') {
						this.queueModel.sendAnswer();
					} else {
						this.queueModel.display();
					}
					break;
				case 'answerView':
					if (transaction === 'assignQuestion') {
						this.answerModel.assignQuestion();
					} else if (transaction === 'anotherQuestion') {
						this.answerModel.anotherQuestion();
					} else if (transaction === 'setProperties') {
						this.answerModel.setProperties(status, results);
					} else {
						this.answerModel.display();
					}
					break;
				case 'rolesView':
					if (transaction === 'presentRoles') {
						this.rolesModel.presentRoles();
					}
					break;
			}
			switch(animation) {
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
	
	function finishTransition(fromView) {
		document.body.removeChild(fromView); // getting itermittent error that fromView does not exist at startup.
	}
};
ViewNavigator.prototype.saveDraft = function() {
	this.answerModel.saveDraft();
};
ViewNavigator.prototype.allCheckboxesOff = function() {
	this.rolesModel.allCheckboxesOff();	
};
ViewNavigator.prototype.registerNewPerson = function() {
	this.rolesModel.registerNewPerson();	
};
