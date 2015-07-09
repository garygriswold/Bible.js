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
//	this.styleIndex = new StyleIndexAdapter(this);
    this.styleIndex = new DeviceCollection(this.database);
//	this.styleUse = new StyleUseAdapter(this);
    this.styleUse = new DeviceCollection(this.database);
//	this.history = new HistoryAdapter(this);
    this.history = new DeviceCollection(this.database);
//	this.questions = new QuestionsAdapter(this);
    this.questions = new DeviceCollection(this.database);
	Object.freeze(this);
}
DeviceDatabase.prototype.select = function(statement, values, callback) {
    this.database.readTransaction(onTranStart, onTranError);

    function onTranStart(tx) {
        console.log(statement, values);
        tx.executeSql(statement, values, onSelectSuccess);
    }
    function onTranError(err) {
        console.log('select tran error', JSON.stringify(err));
        callback(new IOError(err));
    }
    function onSelectSuccess(tx, results) {
        console.log('select success results, rowCount=', results.rows.length);
        callback(results);
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
    var rowCount = 0;
	this.database.transaction(onTranStart, onTranError, onTranSuccess);

    function onTranStart(tx) {
  		console.log('bulk tran start', statement);
  		for (var i=0; i<array.length; i++) {
        	tx.executeSql(statement, array[i], onExecSuccess);
        }
    }
    function onTranError(err) {
        console.log('bulk tran error', JSON.stringify(err));
        callback(new IOError(err));
    }
    function onTranSuccess() {
        console.log('bulk tran completed');
        callback(rowCount);
    }
    function onExecSuccess(tx, results) {
        rowCount += results.rowsAffected;
    }
};
DeviceDatabase.prototype.executeDDL = function(statement, callback) {
    this.database.transaction(onTranStart, onTranError);

    function onTranStart(tx) {
        console.log('exec tran start', statement);
        tx.executeSql(statement, [], onExecSuccess);
    }
    function onTranError(err) {
        callback(new IOError(err));
    }
    function onExecSuccess(tx, results) {
        callback();
    }
};

