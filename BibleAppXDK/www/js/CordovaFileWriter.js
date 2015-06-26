/**
 * This is the Cordova version of the LocalFileWriter
 */
function LocalFileWriter(location) {
    this.location = location;
    Object.seal(this);
}
LocalFileWriter.prototype.createDirectory = function(filepath, callback) {

};
LocalFileWriter.prototype.writeTextFile = function(filename, data, callback) {
    var fs = new DeviceFileSystem(this.location);
    fs.getPersistent(function(fileSystem) {
       console.log('inside get file');
       var options = {create: true, exclusive: true};
       fileSystem.root.getFile(filename, options, onGetFileSuccess, onGetFileError);
    });
    function onGetFileSuccess(fileEntry) {
        console.log('ongetfile success', fileEntry);
        fileEntry.createWriter(onGetWriterSuccess, onGetWriterError);
    }
    function onGetFileError(error) {
        console.log('write file error');//, JSON.stringify(error));
        for (var prop in error) {
            console.log(prop, ' = ', error[prop]);
        }
        callback(error);
    }
    function onGetWriterSuccess(writer) {
        console.log('got writer', writer);
        callback(writer);
        writer.onabort = function(event) {
            console.log('write aborted');
            callback(event);
        };
        writer.onwritestart = function(event) {
            console.log('write started');
        };
        writer.onwrite = function(event) {
            console.log('write happened');
            callback(event);
        };
        writer.onwriteend = function(event) {
            console.log('write ended');
        };
        writer.onerror = function(error) {
            console.log('write error');
            callback(error);
        };
        writer.write(data);
    }
    function onGetWriterError(error) {
        console.log('get writer error', JSON.stringify(error));
        callback(error);
    }
};
