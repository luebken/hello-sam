'use strict';

exports.handler = (event, context, callback) => {
    var s = JSON.stringify(event, null, 2);
    console.log(`Event: ${s}`);
    callback(null, {
        statusCode: '200',
        body: 'Hello world. Arrg',
    });
};
