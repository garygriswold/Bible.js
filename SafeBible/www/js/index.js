/*
* This initializes the App once cordova is ready. 
*/
 var bibleApp = {
    initialize: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    onDeviceReady: function() {
        console.log('DEVICE IS READY **');
        var initializer = new AppInitializer();
        initializer.begin();
    }
}

bibleApp.initialize();

