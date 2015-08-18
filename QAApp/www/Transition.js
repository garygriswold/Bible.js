 /**
* This class is carried as data in a transition event
*/
var TRANSITION = { EVENT: 'transition', IMMEDIATE: 'immediate', SLIDE_LEFT: 'slide-left', SLIDE_RIGHT: 'slide-right' };

console.log('loading dispathTransition starts');
function dispatchTransition(fromView, toView, transType) {
	console.log('inside dispatch transition');
	var evtDetails = { fromView: fromView, toView: toView, transType: transType };
	console.log('DETAILS', JSON.stringify(evtDetails));
	var event = new CustomEvent(TRANSITION.EVENT, { detail: evtDetails });
	document.body.dispatchEvent(event);
}
console.log('loading dispatch ends');