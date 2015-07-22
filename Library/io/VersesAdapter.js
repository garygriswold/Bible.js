/**
* This class is the database adapter for the verses table
*/
function VersesAdapter(database) {
	this.database = database;
	this.className = 'VersesAdapter';
	Object.freeze(this);
}
VersesAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists verses', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop verses success');
			callback();
		}
	});
};
VersesAdapter.prototype.create = function(callback) {
	var statement = 'create table if not exists verses(' +
		'reference text not null primary key, ' +
		'xml text not null, ' +
		'html text not null)';
	this.database.executeDDL(statement, function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('create verses success');
			callback();
		}
	});
};
VersesAdapter.prototype.load = function(array, callback) {
	var statement = 'insert into verses(reference, xml, html) values (?,?,?)';
	this.database.bulkExecuteDML(statement, array, function(count) {
		if (count instanceof IOError) {
			callback(count);
		} else {
			console.log('load verses success, rowcount', count);
			callback();
		}
	});
};
VersesAdapter.prototype.getVerseHTML = function(values, callback) {
	var that = this;
	var statement = createStatement(values.length);
	this.database.select(statement, values, function(results) {
		if (results instanceof IOError) {
			console.log('VersesAdapter select found Error', results);
			callback(results);
		} else if (results.rows.length === 0) {
			callback(new IOError({code: 0, message: 'No Rows Found'}));
		} else {
			var row = results.rows.item(0);
			callback(row.html);
        }
	});
	function createStatement(numValues) {
		if (numValues === 1) {
			return('select html from verses where reference=?');
		} else if (numValues === undefined || numValues === 0) {
			return('select html from verses where reference=XXXXXXXX');
		} else {
			var array = new Array[numValues];
			for (var i=0; i<numValues; i++) {
				array[i] = '?';
			}
			return('select html from verses where reference in (' + array.join(',') + ')');
		}
	}
};