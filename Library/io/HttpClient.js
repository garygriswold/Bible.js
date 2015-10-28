/**
* This class encapsulates the get and post to the BibleApp Server
* from the BibleApp
*/
function HttpClient(server, port) {
	this.server = server;
	this.port = port;
	this.authority = 'http://' + this.server + ':' + this.port;
}
HttpClient.prototype.get = function(path, callback) {
	this.request('GET', path, null, callback);
};
HttpClient.prototype.put = function(path, postData, callback) {
	this.request('PUT', path, postData, callback);
};
HttpClient.prototype.post = function(path, postData, callback) {
	this.request('POST', path, postData, callback);
};
HttpClient.prototype.request = function(method, path, postData, callback) {
	console.log(method, path, postData);	
	var request = createRequest();
	if (request) {
		request.onreadystatechange = progressEvents;
		request.open(method, this.authority + path, true);
		var data = (postData) ? JSON.stringify(postData) : null;
		if (data) {
			request.setRequestHeader('Content-Type', 'application/json');
		}
		request.send(data);		
	} else {
		callback(-2, new Error('XMLHttpRequest was not created.'));
	}

	function progressEvents() {
		try {
	    	if (request.readyState === 4) {
		    	if (request.status === 0) {
			    	callback(request.status, new Error('Could not reach the server, please try again when you have a better connection.'));
		    	} else {
		    		callback(request.status, JSON.parse(request.responseText));
		    	}
	    	}
	    } catch(error) {
		    callback(-1, error);
	    }
  	}

	function createRequest() {
		var request;
		if (window.XMLHttpRequest) { // Mozilla, Safari, ...
			request = new XMLHttpRequest();
    	} else if (window.ActiveXObject) { // IE
			try {
				request = new ActiveXObject("Msxml2.XMLHTTP");
      		} 
	  		catch (e) {
	  			try {
	  				request = new ActiveXObject("Microsoft.XMLHTTP");
        		} 
				catch (e) {}
      		}
    	}
    	return(request);
	}
};

