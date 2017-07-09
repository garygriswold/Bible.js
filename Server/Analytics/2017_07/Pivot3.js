
"use strict";

var pivot3 = function() {
	console.log('Hello World');	
	
	var args = process.argv;
	console.log(process.argv);
	if (args.length < 7) {
		fatalError(null, "Parameters: databaseName, tableName, xAxisColumn, yAxisColumn, value");
	}
	var Sqlite = require('../../aws/desktop/Sqlite.js');
	
	var databaseName = args[2];
	var tableName = args[3];
	var xAxisCol = args[4];
	var yAxisCol = args[5];
	var valCol = args[6];
	var xAxis = [];
	var yAxis = [];
	var matrix = [];
	var database = new Sqlite(databaseName, true);
	console.log(databaseName, tableName, xAxisCol, yAxisCol, valCol);
	
	var statement = "SELECT distinct " + xAxisCol + " FROM " + tableName + " ORDER BY " + xAxisCol;
	database.selectAll(statement, [], function(xAxisArray) {
		for (var i=0; i<xAxisArray.length; i++) {
			xAxis.push(xAxisArray[i][xAxisCol]);
		}
		//console.log(xAxis);
		statement = "SELECT distinct " + yAxisCol + " FROM " + tableName + " ORDER BY " + yAxisCol;
		database.selectAll(statement, [], function(yAxisArray) {
			for (i=0; i<yAxisArray.length; i++) {
				yAxis.push(yAxisArray[i][yAxisCol])
			}
			//console.log(yAxis);
			matrix = new Array(xAxis.length);
			for (var i=0; i<xAxis.length; i++) {
				matrix[i] = new Array(yAxis.length);
				for (var j=0; j<yAxis.length; j++) {
					matrix[i][j] = 0;
				}
			}
			//console.log(matrix);
			statement = "SELECT " + xAxisCol + ", " + yAxisCol + ", " + valCol + " FROM " + tableName;  
			database.selectAll(statement, [], function(results) {
				processResult(0, results);
			});
		});		
	});
	
	function processResult(index, results) {
		if (index < results.length) {
			var row = results[index];
			//console.log(row);
			var xAxisItem = row[xAxisCol];
			var yAxisItem = row[yAxisCol];
			var valItem = row[valCol];
			
			var xAxisIndex = xAxis.indexOf(xAxisItem);
			if (xAxisIndex < 0) fatalError(null, "No xAxis for " + xAxisItem);
			var yAxisIndex = yAxis.indexOf(yAxisItem);
			if (yAxisIndex < 0) fatalError(null, "No yAxis for " + yAxisItem);
			
			matrix[xAxisIndex][yAxisIndex] = valItem;
			
			processResult(index + 1, results);
		} else {
			database.close();
			//console.log(matrix);
			var table = displayResultTable();
			var fs = require('fs');
			fs.writeFileSync(tableName + ".csv", table);
		}
	}
	
	function displayResultTable() {
		var table = []
		var line = yAxis;
		line.unshift(xAxisCol);
		//console.log(line.join(","));
		table.push(line.join(","));
		for (var i=0; i<xAxis.length; i++) {
			line = matrix[i];
			line.unshift(xAxis[i]);
			//console.log(line.join(","));
			table.push(line.join(","));
		}
		return(tableName, table.join("\n"));
	}

	function fatalError(error, message) {
		var message = (error != null) ? error.toString() + " " + message : message;
		console.log("Error: " + message);
		database.close();
		process.exit(1);
	}
};


pivot3();




