/**
* This class is the database adapter for the concordance table
*/
function ConcordanceAdapter(database) {
	this.database = database;
	this.className = 'ConcordanceAdapter';
	Object.freeze(this);
}
ConcordanceAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists concordance', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop concordance success');
			callback();
		}
	});
};
ConcordanceAdapter.prototype.create = function(callback) {
	var statement = 'create table if not exists concordance(' +
		'word text primary key not null, ' +
    	'refCount integer not null, ' +
    	'refList text not null, ' + // comma delimited list of references where word occurs
    	'refPosition text not null)';  // comma delimited list of references with position in verse.
   	this.database.executeDDL(statement, function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('create concordance success');
			callback();
		}
	});
};
ConcordanceAdapter.prototype.load = function(array, callback) {
	var statement = 'insert into concordance(word, refCount, refList, refPosition) values (?,?,?,?)';
	this.database.bulkExecuteDML(statement, array, function(count) {
		if (count instanceof IOError) {
			callback(count);
		} else {
			console.log('load concordance success', count);
			callback();
		}
	});
};
ConcordanceAdapter.prototype.select = function(words, callback) {
	var values = [ words.length ];
	var questMarks = [ words.length ];
	for (var i=0; i<words.length; i++) {
		values[i] = words[i].toLocaleLowerCase();
		questMarks[i] = '?';
	}
	var statement = 'select refList from concordance where word in(' + questMarks.join(',') + ')';
	this.database.select(statement, values, function(results) {
		if (results instanceof IOError) {
			console.log('found Error', results);
			callback(results);
		} else {
			var refLists = [];
			for (i=0; i<results.rows.length; i++) {
				var row = results.rows.item(i);
				if (row && row.refList) { // ignore words that have no ref list
					var array = row.refList.split(',');
					refLists.push(array);
				}
			}
            callback(refLists);
        }
	});
};