var fs = require('fs');
var https = require('https');
var httpSignature = require('http-signature');

var options = {
  //key: fs.readFileSync('./key.pem'),
  //cert: fs.readFileSync('./cert.pem')
  key: fs.readFileSync('./ssh/id_rsa.pub'),
  cert: fs.readFileSync('./ssh/id_rsa')
};

https.createServer(options, function (req, res) {
  var rc = 200;
  var parsed = httpSignature.parseRequest(req);
  //var pub = fs.readFileSync(parsed.keyId, 'ascii');
  var pub = fs.readFileSync('ssh/id_rsa');
  if (!httpSignature.verifySignature(parsed, pub))
    rc = 401;

  res.writeHead(rc);
  res.end();
}).listen(8443);