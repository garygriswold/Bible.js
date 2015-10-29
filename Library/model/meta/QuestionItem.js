/**
* This class contains the contents of one user question and one instructor response.
*/
function QuestionItem(reference, displayRef, question, askedDt, instructor, answerDt, answer) {
	this.discourseId = null;
	this.reference = reference;
	this.displayRef = displayRef;
	this.question = question;
	this.askedDateTime = askedDt;
	this.instructor = instructor;
	this.answerDateTime = answerDt;
	this.answer = answer;
	Object.seal(this);
}