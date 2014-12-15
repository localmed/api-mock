winston = require 'winston'

class CorsSupport
  constructor: (app) ->

    app.all '*', (req, res, next) ->
      unless req.get('Origin')
        next()
      else
        res.set('Access-Control-Allow-Origin', "*")
        res.set('Access-Control-Allow-Methods', req.method)
        res.set('Access-Control-Allow-Headers', req.headers['access-control-request-headers'])

        if 'OPTIONS' == req.method
          res.send(200);
        else
          next()

    winston.info "Enabled Cross-Origin-Resource-Sharing (CORS)"
    winston.info "\tAllow-Origin: #{options.origin}"
    winston.info "\tAllow-Methods: #{options.methods}"
    winston.info "\tAllow-Headers: #{options.headers}"

module.exports = CorsSupport
