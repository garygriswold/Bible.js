/**
* This class is the database adapter for the codex table
*/
function ChaptersAdapter(database) {
	this.database = database;
	this.className = 'ChaptersAdapter';
	Object.freeze(this);
}
ChaptersAdapter.prototype.drop = function(callback) {
	this.database.executeDDL('drop table if exists codex', function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('drop codex success');
			callback();
		}
	});
};
ChaptersAdapter.prototype.create = function(callback) {
	var statement = 'create table if not exists codex(' +
		'book text not null, ' +
		'chapter integer not null, ' +
		'xml text not null, ' +
		'html text null, ' +
		'primary key (book, chapter))';
	this.database.executeDDL(statement, function(err) {
		if (err instanceof IOError) {
			callback(err);
		} else {
			console.log('create codex success');
			callback();
		}
	});
};
ChaptersAdapter.prototype.load = function(array, callback) {
	var statement = 'insert into codex(book, chapter, xml, html) values (?,?,?,?)';
	this.database.bulkExecuteDML(statement, array, function(count) {
		if (count instanceof IOError) {
			callback(count);
		} else {
			console.log('load codex success, rowcount', count);
			callback();
		}
	});
};
ChaptersAdapter.prototype.getChapterHTML = function(values, callback) {
	var that = this;
	var statement = 'select html from codex where book=? and chapter=?';
	var array = [ values.book, values.chapter ];
	this.database.select(statement, array, function(results) {
		if (results instanceof IOError) {
			console.log('found Error', results);
			callback(results);
		} else if (results.rows.length === 0) {
			callback();
		} else {
			var row = results.rows.item(0);
			callback(row.html);
        }
	});
};
ChaptersAdapter.prototype.getChapters = function(values, callback) {
	var that = this;
	var statement = 'select xml from codex where book=? and chapter=?';
	var array = [ values.book, values.chapter ];
	this.database.select(statement, array, function(results) {
		if (results instanceof IOError) {
			console.log('found Error', results);
			callback(results);
		} else if (results.rows.length === 0) {
			callback();
		} else {
			var row = results.rows.item(0);
			callback(row.xml);
        }
	});
};