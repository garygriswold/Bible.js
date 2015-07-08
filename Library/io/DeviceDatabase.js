/**
* This class is a facade over the database that is used to store bible text, concordance,
* table of contents, history and questions.
*/
function DeviceDatabase(code, name) {
	this.code = code;
	this.name = name;
    this.className = 'DeviceDatabase';
	var size = 30 * 1024 * 1024;
	this.database = window.openDatabase(this.code, "1.0", this.name, size);
	this.codex = new CodexAdapter(this);
	this.tableContents = new TableContentsAdapter(this);
	this.concordance = new ConcordanceAdapter(this);
	this.styleIndex = new StyleIndexAdapter(this);
	this.styleUse = new StyleUseAdapter(this);
	this.history = new HistoryAdapter(this);
	this.questions = new QuestionsAdapter(this);
	Object.freeze(this);
}
DeviceDatabase.prototype.select = function(statement, values, callback) {
    this.database.readTransaction(onTranStart, onTranError, onTranSuccess);

    function onTranStart(tx) {
        console.log(statement, values);
        tx.executeSql(statement, values, onSelectSuccess, onSelectError);
    }
    function onTranError(err) {
        console.log('select tran error', JSON.stringify(err));
        callback(new IOError(err));
    }
    function onTranSuccess() {
    	console.log('select tran success');
    	callback();
    }
    function onSelectSuccess(tx, results) {
        console.log('select success results', JSON.stringify(results.rows));
        callback(results);
    }
    function onSelectError(tx, err) {
        console.log('select error', err);
        callback(new IOError(err));
    }
};
DeviceDatabase.prototype.executeDML = function(statement, values, callback) {
    var rowsAffected;
    this.database.transaction(onTranStart, onTranError, onTranSuccess);

    function onTranStart(tx) {
        console.log('exec tran start', statement, values);
        tx.executeSql(statement, values, onExecSuccess, onExecError);
    }
    function onTranError(err) {
        console.log('execute tran error', JSON.stringify(err));
        callback(new IOError(err));
    }
    function onTranSuccess() {
        console.log('execute trans completed', rowsAffected);
        callback(rowsAffected);
    }
    function onExecSuccess(tx, results) {
    	console.log('excute sql success', results.rowsAffected);
        rowsAffected = results.rowsAffected;
    	//if (results.rowsAffected === 0) {
    	//	callback(new IOError(1, 'No rows affected by update'));
    	//} else {
    	//	callback();
    	//}
    }
    function onExecError(tx, err) {
    	console.log('execute sql error', JSON.stringify(err));
    	callback(new IOError(err));
    }
};
DeviceDatabase.prototype.bulkExecuteDML = function(statement, array, callback) {
	this.database.transaction(onTranStart, onTranError, onTranSuccess);

    function onTranStart(tx) {
  		console.log('bulk tran start', statement, array[0], onExecSuccess, onExecError);
  		for (var i=0; i<array.length; i++) {
        	tx.executeSql(statement, array[i]);
        }
    }
    function onTranError(err) {
        console.log('bulk tran error', JSON.stringify(err));
        callback(new IOError(err));
    }
    function onTranSuccess() {
        console.log('bulk tran completed');
        callback();
    }
    function onExecSuccess(tx, results) {
    	if (results.rowsAffected !== array.length) {
    		callback(new IOError(1, array.length + ' rows input, but ' + results.rowsAffected + ' processed.'));
    	} else {
    		callback();
    	}
    }
    function onExecError(tx, err) {
    	console.log('bulk sql error', JSON.stringify(err));
    	callback(IOError(err));
    }
};
DeviceDatabase.prototype.executeDDL = function(statement, callback) {
    this.database.transaction(onTranStart, onTranError);

    function onTranStart(tx) {
        console.log('exec tran start', statement);
        tx.executeSql(statement, [], onExecSuccess, onExecError);
    }
    function onTranError(err) {
        callback(new IOError(err));
    }
    function onExecSuccess(tx, results) {
        callback();
    }
    function onExecError(tx, err) {
        callback(new IOError(err));
    }
};

