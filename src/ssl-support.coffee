https = require 'https'
fs = require 'fs'
winston = require 'winston'

class SslSupport

  constructor: (app, options) ->

    serverOptions =
      key: fs.readFileSync(options.key)
      cert: fs.readFileSync(options.cert)

    https.createServer(serverOptions, app).listen(options.port, options.host);

    winston.info('Listening on ' + options.host + ':' + options.port + ' (HTTPS)');


module.exports = SslSupport
