'use strict';

exports.handler = (event, context, callback) => {
    console.log(`Event: ${JSON.stringify(event, null, 2)}`);
    callback(null, 'body');
};
