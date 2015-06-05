/**
* This class contains the contents of one user question and one instructor response.
*/
function QuestionItem(reference, nodeId, question, askedDt, instructor, answerDt, answer) {
	this.reference = reference;
	this.referenceNodeId = nodeId;
	this.questionText = question;
	this.askedDateTime = askedDt || new Date();
	this.instructorName = instructor;
	this.answeredDateTime = answerDt;
	this.answerText = answer;
	Object.seal(this);
}