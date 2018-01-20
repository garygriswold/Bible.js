

"use strict";

var pieChart = function() {
	console.log('Hello World');	
	
	var args = process.argv;
	console.log(process.argv);
	if (args.length < 7) {
		fatalError(null, "Parameters: databaseName tableName chartColumn pieceColumn value");
	}
	var Sqlite = require('../../aws/desktop/Sqlite.js');
	
	var databaseName = args[2];
	var tableName = args[3];
	var chartCol = args[4];
	var pieceCol = args[5];
	var valCol = args[6];
	var charts = [];
	var pieces = [];
	var matrix = [];
	
	var database = new Sqlite(databaseName, true);
	console.log(databaseName, tableName, chartCol, pieceCol, valCol);

	var statement = 'SELECT distinct ' + chartCol + ' FROM ' + tableName;
	database.selectAll(statement, [], function(chartArray) {
		for (var i=0; i<chartArray.length; i++) {
			charts.push(chartArray[i][chartCol]);
		}
		console.log(charts);
		processCharts(0, charts);
	});
	
	function processCharts(index, chartArray) {
		if (index < chartArray.length) {
			var chart = chartArray[index];
			statement = 'SELECT ' + pieceCol + ', ' + valCol + ' FROM ' + tableName + ' WHERE ' + valCol + ' !=0' + ' AND ' + chartCol + " = '" + chart + "'";
			database.selectAll(statement, [], function(results) {
				console.log(results);
				outputChart(chart, results);
				processCharts(index + 1, chartArray);
			});
		} else {
			database.close();
		}
	}
	
	function outputChart(chart, results) {
		var sumCount = 0;
		var table = [];
		table.push('Country, Count');
		for (var i=0; i<results.length; i++) {
			var row = results[i];
			table.push(row[pieceCol] + ', ' + row[valCol]);
			sumCount += row[valCol];
		}
		table.push('TOTAL, ' + sumCount);
		table.push('SQRT, ' + Math.sqrt(sumCount));
		var fs = require('fs');
		fs.writeFileSync(chart + ".csv", table.join("\n"));
	}
	
	function fatalError(error, message) {
		var message = (error != null) ? error.toString() + " " + message : message;
		console.log("Error: " + message);
		database.close();
		process.exit(1);
	}
};


//2. for each version
//2a. get sum of count
//2a. select country, count where count != 0
//2c. output in columns Country.cvs (country, count) + total, count + sqrt, count


pieChart();