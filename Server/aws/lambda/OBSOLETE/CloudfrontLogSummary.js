'use strict';
const aws = require('aws-sdk');
const s3 = new aws.S3();
const zlib = require('zlib');

exports.logHandler = (event, context) => {
    //console.log('Received event:', JSON.stringify(event, null, 2));

    var output = [];
    const record = event.Records[0];
    const bucket = record.s3.bucket.name;
    const key = decodeURIComponent(record.s3.object.key.replace(/\+/g, ' '));
    const rawLog = { Bucket: bucket, Key: key };
    console.log('Bucket', bucket, 'Key', key);
    s3.getObject(rawLog, function(as3Error, as3Data) {
       if (as3Error) {
           console.log('ERROR s3.getObject', as3Error);
       } else {
           zlib.unzip(as3Data.Body, function(zipError, zipData) {
               if (zipError) {
                   console.log('ERROR zlib.gunzip', zipError);
               } else {
                   var insert = 'INSERT INTO Downloads' +
                   '(date, time, file, prefLang, locale, prior, status, edgeType, edgeLoc, duration)' +
                   ' VALUES (?,?,?,?,?,?,?,?,?,?)';
                   //console.log(insert.join(''));
                   output.push(insert);
                   const log = String(zipData).trim().split('\n');
                   for (var i=2; i<log.length; i++) {
                        var line = log[i].split('\t');
                        var values = [];
                        values.push('[' + line[0]); // date
                        values.push(line[1]); // time
                        values.push(line[7].replace('/', '')); // file
                        const cookie = line[12].split(';');
                        const lang = cookie[0].split(',');
                        values.push(lang[0]); // pref-lang
                        values.push(lang[1]); // locale
                        values.push(cookie[1]); // prior
                        values.push(line[8]); // status
                        values.push(line[13]); // edge-type
                        values.push(line[2]); // edge-loc
                        values.push(line[18] + ']'); // time-taken
                        //console.log(values.join(','));
                        output.push(values.join(','));
                   }
                   console.log(output.join('\n'));
                   const newKey = 'LOG_' + record.eventTime;
                   var params = { Bucket: 'shortcloud', Key: newKey, Body: output.join('\n') };
                   s3.putObject(params, function(putError, data) {
                        if (putError) {
                            console.log('ERROR in S3.putObject', putError);
                        }
                        else {
                            console.log("Successfully wrote Summary to shortcloud");
                            s3.deleteObject(rawLog, function(delError, data) {
                                if (delError) {
                                    console.log('ERROR in S3.deleteObject', delError);
                                } else {
                                    console.log('Successfully deleted log from shortlog');
                                }
                            });
                        }
                   });
               }
           });
        }
    });
};