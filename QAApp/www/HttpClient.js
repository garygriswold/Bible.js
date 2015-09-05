/**
* This class encapsulates the get and post to the BibleApp Server
*/
function HttpClient(server, port) {
	this.server = server;
	this.port = port;
	this.authority = 'http://' + this.server + ':' + this.port;
}
HttpClient.prototype.get = function(path, callback) {
	console.log('inside get', path);
	this.request('GET', path, null, callback);
};
HttpClient.prototype.put = function(path, postData, callback) {
	this.request('PUT', path, postData, callback);
};
HttpClient.prototype.post = function(path, postData, callback) {
	this.request('POST', path, postData, callback);
};
HttpClient.prototype.delete = function(path, callback) {
	this.request('DELETE', path, postData, callback);
};
HttpClient.prototype.request = function(method, path, postData, callback) {
	var request = createRequest();
	if (request) {
		request.onreadystatechange = progressEvents;
		request.open(method, this.authority + path, true);
		if (postData) {
			request.setRequestHeader('Content-Type', 'application/json');
			request.setRequestHeader('Content-Length', postData.length);
		}		
		request.send(postData);		
	} else {
		window.alert('Please try a different web browser.  This one does not have the abilities needed.');
		callback(-1, '');
	}

	function progressEvents() {
		try {
	    	if (request.readyState === 4) {
		    	callback(request.status, request.responseText);
	    	}
	    } catch(error) {
		    callback(-1, error)
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


/*
	request.timeout = ms;
	request.onTimeout = function;
*/