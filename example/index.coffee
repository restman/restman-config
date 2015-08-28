config = require('../')("#{__dirname}/config")

console.log config

console.log config.has('app.name')

console.log config.get('app.name')