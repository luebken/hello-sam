'use strict';

var AWS = require('aws-sdk');
// http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/DynamoDB/DocumentClient.html
var dynamo = new AWS.DynamoDB.DocumentClient({endpoint: 'http://localhost:8000'});
var table = process.env.TABLE_NAME;

exports.handler = (event, context, callback) => {

    console.log(`Event: ${JSON.stringify(event, null, 2)}`);

    var params = {
        TableName: table,
        Item: {
            "id": "xp", //TODO hardcoded
            "thing": event.queryStringParameters.message
        }
    };

    console.log(`Adding >${params.Item.id}< to table >${params.TableName}< ...`);
    dynamo.put(params, function (err, data) {

        console.log('err', err)
        console.log('data', data)

        if (err) {
            callback(err, {
                statusCode: '500',
                body: JSON.stringify(err, null, 2)
            });
        } else {
            callback(err, {
                statusCode: '200',
                body: JSON.stringify(data, null, 2)
            });
        }
    });


};
