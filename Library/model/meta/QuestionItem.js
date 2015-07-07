/**
* This class contains the contents of one user question and one instructor response.
*/
function QuestionItem(reference, nodeId, question, askedDt, instructor, answerDt, answer) {
	this.reference = reference;
	this.nodeId = nodeId;
	this.questionText = question;
	this.askedDateTime = (askedDt) ? new Date(askedDt) : new Date();
	this.instructorName = instructor;
	this.answeredDateTime = (answerDt) ? new Date(answerDt) : null;
	this.answerText = answer;
	Object.seal(this);
}