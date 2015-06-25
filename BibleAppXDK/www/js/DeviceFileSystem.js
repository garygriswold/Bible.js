/**
 * This class holds the persistent file location
 * and insures adequate allocation of storage.
 */
function DeviceFileSystem(location) {
    this.persistentFileSystem = undefined;
    Object.seal(this);
    console.log('inside new');
}

DeviceFileSystem.prototype.getPersistent = function(callback) {
	console.log('inside localfilelocation');
	var that = this;
    if (this.persistentFileSystem) {
		console.log('immediate callback');
        callback(this.persistentFileSystem);
    } else {
		console.log('do allocate');
        //var allocate = 1024 * 1024 * 1024; // 1 GB
        window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, onSuccess, onError);
		console.log('after allocate');
    }
    function onSuccess(fs) {
        that.persistentFileSystem = fs;
        console.log('success');
        console.log("FS %O", fs);
        console.log("ROOT %O", fs.root);
        console.log("URL %O", fs.root.fullPath);
        callback(that.persistentFileSystem);
    }
    function onError(err) {
        console.log('LocalFileSystem.getPersistent', err);
        callback(null);
    }
};