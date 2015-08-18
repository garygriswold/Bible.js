 /**
* This class is carried as data in a transition event
*/
var TRANSITION = { EVENT: 'transition', IMMEDIATE: 'immediate', SLIDE_LEFT: 'slide-left', SLIDE_RIGHT: 'slide-right' };

function dispatchTransition(fromView, toView, transType) {
	var evtDetails = { fromView: fromView, toView: toView, transType: transType };
	var event = new CustomEvent(TRANSITION.EVENT, { detail: evtDetails });
	document.body.dispatchEvent(event);
}