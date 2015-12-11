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
        console.log('DEVICE IS READY **');
        FastClick.attach(document.body);

        var settingStorage = new SettingStorage();
		settingStorage.getCurrentVersion(function(version) {
			if (version == null) {
				version = 'WEB.db1'; // Where does the defalt come from.  There should be one for each major language.
				settingStorage.setCurrentVersion(version);
			}
			changeVersionHandler(version);
		});
			
		document.body.addEventListener(BIBLE.CHG_VERSION, function(event) {
			// find the version in the event
			changeVersionHandler(version);
		});
		function changeVersionHandler(version) {
			app = new AppViewController(version, settingStorage);
			app.begin();
		}
    }
}

app.initialize();