/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var app = {
    // Application Constructor
    initialize: function() {
        this.bindEvents();
    },
    // Bind Event Listeners
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent'
    // function, we must explicitly call 'app.receivedEvent(...);'
    onDeviceReady: function() {
        app.receivedEvent('deviceready');
    },
    // Update DOM on a Received Event
    receivedEvent: function(id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id);
        console.log('DEVICE IS READY **');
        var appView = new AppViewController('WEB');
        //appView.begin('TableContentsView');
        //appView.begin('SearchView');
        //appView.begin('QuestionsView')
        //appView.begin('HistoryView');
        appView.begin();

        /*
        var db = window.openDatabase('WEB', "1.0", 'WEB', 20*1024*1024);
        console.log('past open database');
        console.log('db', JSON.stringify(db));
        db.transaction(onTranSuccess, onTranError);//, onTranVoid);
        console.log('past transaction');

        function onTranSuccess(tx) {
            console.log('have transaction');
            console.log('trans', JSON.stringify(tx));
            tx.executeSql('create table if not exists abc(a int)');
            console.log('after create table');
            tx.executeSql('insert into abc (a) values (1)');
            console.log('after insert into (1)');
            tx.executeSql('insert into abc (a) values (2)');
            console.log('after insert into (2)');
            tx.executeSql('select * from abc', [], function(tx, results) {
                var len = results.rows.length;
                console.log('results len=', len);
                for (var i=0; i<len; i++) {
                    console.log(results.rows.item(i));
                }
            });
        }
        function onTranError(err) {
            console.log('have tran error');
            console.log('error', JSON.stringify(err));
        }
        function onTranVoid(err) {
            console.log('have tran void');
            console.log('error', JSON.stringify(err));
        }
        var fileTransfer = new FileTransfer();
        var uri = encodeURI('http://www.google.com');
        var fileURL = 'cdvfile://localhost/cordova.file.dataDirectory/sample8.txt';

        fileTransfer.download(
            uri,
            fileURL,
            function(entry) {
                console.log("download complete: " + entry.toURL());
            },
            function(error) {
                console.log("download error source " + error.source);
                console.log("download error target " + error.target);
                console.log("upload error code" + error.code);
            },
            false,
                {
                    headers: {"Authorization": "Basic dGVzdHVzZXJuYW1lOnRlc3RwYXNzd29yZA==" }
                }
        );
*/
    }
}

app.initialize();