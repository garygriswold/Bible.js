/**
* This function is a Unit Test for the Concordance Search method
*/
function runUnitTest() {
	console.log('START TEST');
	var database = new DatabaseHelper('WEB_SHORT.db', false);
	var adapter = new ConcordanceAdapter(database);
	var lookAhead = 2;
	var concordance = new Concordance(adapter, lookAhead);
	runOneTest(0);
	
	function runOneTest(index) {
		console.log('DO TEST', index);
		if (index < concordanceTests.length) {
			var test = concordanceTests[index];
			concordance.search2(test.words, function(results) {
				if (results.length !== test.results.length) {
					errorMessage('INCORRECT NUM VERSES FOUND', results, test);
				} else {
					for (var w=0; w<results.length; w++) {
						var expectVerse = test.results[w];
						var foundVerse = results[w];
						if (expectVerse.length !== foundVerse.length) {
							errorMessage('INCORRECT NUM WORDS FOUND', results, test);
						} else {
							for (var p=0; p<foundVerse.length; p++) {
								if (expectVerse[p] !== foundVerse[p]) {
									errorMessage('INCORRECT VERSE FOUND', results, test);
								}
							}
						}
					}
				}
				console.log('DONE', test.words, results);
				runOneTest(index + 1);
			});
		}
		else {
			console.log('TEST SUCCESS');
			process.exit(0);
		}
	}
	
	function errorMessage(message, results, test) {
		console.log('ERROR', message);
		console.log('EXPECTED', test.results);
		console.log('FOUND', results);
		process.exit(1);
	}
}


var concordanceTests = [
	{ words: ['servant', 'God', 'apostle', 'Jesus', 'Christ'], results: [['TIT:1:1;3', 'TIT:1:1;5', 'TIT:1:1;8', 'TIT:1:1;10', 'TIT:1:1;11']] },
	{ words: ['hope', 'eternal', 'life', 'which', 'God', 'lie', 'promised'], results: [['TIT:1:2;2', 'TIT:1:2;4', 'TIT:1:2;5', 'TIT:1:2;6', 'TIT:1:2;7', 'TIT:1:2;10', 'TIT:1:2;11']] },
	{ words: ['but', 'in', 'his', 'own', 'time'], results: [['TIT:1:3;1', 'TIT:1:3;2', 'TIT:1:3;3', 'TIT:1:3;4', 'TIT:1:3;5']] },
	//{ words:['Paul', 'a', 'servant', 'of', 'God', 'and', 'an', 'apostle', 'of', 'Jesus', 'Christ', 'according', 'to', 'the', 'faith', 'of', "God's", 'chosen', 'ones', 'and', 'the', 'knowledge', 'of', 'the', 'truth', 'which', 'is', 'according', 'to', 'godliness'], results:[['TIT:1:1;1']]},
	{ words:['promised', 'began'], results:[['TIT:1:2;11', 'TIT:1:2;14']] }	
];