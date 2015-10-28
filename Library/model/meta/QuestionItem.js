/**
* This class contains the contents of one user question and one instructor response.
*/
function QuestionItem(reference, displayRef, question, askedDt, instructor, answerDt, answer) {
	this.reference = reference;
	this.displayRef = displayRef;
	this.question = question;
	this.askedDateTime = (askedDt) ? new Date(askedDt) : new Date();
	this.instructor = instructor;
	this.answerDateTime = (answerDt) ? new Date(answerDt) : null;
	this.answer = answer;
	Object.seal(this);
}