'use strict';
const aws = require('aws-sdk');
const s3 = new aws.S3();

exports.logHandler = function(event, context) {
    console.log('Received event:', JSON.stringify(event, null, 2));
    var output = [];
    const record = event.Records[0];
    const bucket = record.s3.bucket.name;
    const key = decodeURIComponent(record.s3.object.key.replace(/\+/g, ' '));
    // Uncomment for unit test
    //const bucket = 'shortsands-drop';
    //const key = '2016-11-29-05-28-51-8DEF77A9EC4E1725';
    const rawLog = { Bucket: bucket, Key: key };
    console.log('Processing: Bucket', bucket, 'Key', key);
    s3.getObject(rawLog, function(as3Error, as3Data) {
        if (as3Error) {
            console.log('ERROR s3.getObject', as3Error);
        } else {
            const log = String(as3Data.Body).trim().split('\n');
            console.log('LOG', log);
            for (var i=0; i<log.length; i++) {
                var line = parseLogLine(log[i]);
                var values = [];
                // line[0] user id of bucket owner
                values.push('"bucket":"' + line[1] + '"');
                values.push('"datetime":"' + line[2] + '"');
                // line[3] remote IP
                values.push('"userid":"' + line[4] + '"');
                values.push('"requestid":"' + line[5] + '"');
                values.push('"operation":"' + line[6] + '"');
                values.push('"filename":"' + line[7] + '"');
                var lang = parseLocale(line[8]);
                if (lang) {
                    var langParts = lang.split(',');
                    values.push('"prefLocale":"' + langParts[0] + '"');
                    if (langParts.length > 1) {
                        values.push('"locale":"' + langParts[1] + '"');
                    }
                }
                values.push('"httpStatus":"' + line[9] + '"');
                values.push('"error":"' + line[10] + '"');
                values.push('"tranSize":"' + line[11] + '"');
                values.push('"fileSize":"' + line[12] + '"');
                values.push('"totalms":"' + line[13] + '"');
                values.push('"s3ms":"' + line[14] + '"');
                // line[15] referrer
                values.push('"userAgent":"' + line[16] + '"');
                output.push('{ ' + values.join(', ') + ' }');
            }
            console.log(output.join('\n'));
            var params = { 
                Bucket: 'shortsands-log', 
                Key: key + '.json',
                ContentType: 'application/json',
                Body: output.join('\n')
            };
            s3.putObject(params, function(putError, data) {
                if (putError) {
                    console.log('ERROR in S3.putObject', putError);
                }
                else {
                    console.log("Successfully wrote Summary to shortsands-log");
                    s3.deleteObject(rawLog, function(delError, data) {
                        if (delError) {
                            console.log('ERROR in S3.deleteObject', delError);
                        } else {
                            console.log('Successfully deleted log from shortsands-drop');
                        }
                    });
                }
            });
        }
    });
    
    function parseLogLine(line) {
        var lineOut = [];
        var field = [];
        var inside = false;
        for (var i=0; i<line.length; i++) {
            var chr = line[i];
            switch(chr) {
                case ' ':
                    if (inside) {
                        field.push(chr);
                    } else {
                        lineOut.push(field.join(''));
                        field = [];
                    }
                    break;
                case '"':
                    inside = !inside;
                    break;
                case '[':
                    inside = true;
                    break;
                case ']':
                    inside = false;
                    break;
                default:
                    field.push(chr);
                    break;
            }
        }
        if (field.length > 0) {
            lineOut.push(field.join(''));
        }
        console.log('END', lineOut);
        return(lineOut);
    }
    
    function parseLocale(url) {
        var locale = url.indexOf('?X-Locale=');
        if (locale > -1) {
            var endLocale = url.indexOf('&', locale);
            if (endLocale > -1) {
                return(url.substring(locale + 10, endLocale));
            }
        }
        return(null);
    }
};