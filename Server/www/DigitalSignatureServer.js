var fs = require('fs');
var http = require('http');
var httpSignature = require('http-signature');

http.createServer(function(req, res) {
  var rc = 200;
  var parsed = httpSignature.parseRequest(req);
  var pub = fs.readFileSync(parsed.keyId, 'ascii');
  if (!httpSignature.verifySignature(parsed, pub))
    rc = 401;

  res.writeHead(rc);
  res.end();
}).listen(8443);