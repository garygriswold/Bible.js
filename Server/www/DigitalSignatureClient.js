var fs = require('fs');
var https = require('https');
var httpSignature = require('http-signature');

//var key = fs.readFileSync('./key.pem', 'ascii');
var key = fs.readFileSync('ssh/id_rsa.pub');

var options = {
  host: 'localhost',
  port: 8443,
  path: '/',
  method: 'GET',
  headers: {}
};

// Adds a 'Date' header in, signs it, and adds the
// 'Authorization' header in.
var req = https.request(options, function(res) {
  console.log(res.statusCode);
});


httpSignature.sign(req, {
  key: key,
  keyId: './cert.pem'
});

req.end();

