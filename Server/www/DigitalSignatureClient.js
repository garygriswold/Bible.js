var fs = require('fs');
var http = require('http');
var httpSignature = require('http-signature');

var key = fs.readFileSync('./private.pem', 'ascii');
console.log("KEY", key);

var options = {
  host: 'localhost',
  port: 8443,
  path: '/',
  method: 'GET',
  headers: {}
};

// Adds a 'Date' header in, signs it, and adds the
// 'Authorization' header in.
var req = http.request(options, function(res) {
  console.log(res.statusCode);
});

httpSignature.sign(req, {
  key: key,
  keyId: './public.pem'
});

req.end();


/*

openssl genpkey -algorithm RSA -out private.pem
openssl pkey -pubout -in private.pem -out public.pem

*/

