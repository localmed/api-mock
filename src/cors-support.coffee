winston = require 'winston'

class CorsSupport
  constructor: (app, configuration) ->

    options =
      origin: '*'
      methods: 'GET, PUT, POST, PATCH, DELETE, TRACE, OPTIONS'
      headers: 'Origin, X-Requested-With, Content-Type, Accept, Authorization, Referer, Prefer'

    if configuration.headers
      options.headers = options.headers + ', ' + configuration.headers

    app.all '*', (req, res, next) ->
      unless req.get('Origin')
        next()
      else
        res.set 'Access-Control-Allow-Origin', options.origin
        res.set 'Access-Control-Allow-Methods', options.methods
        res.set 'Access-Control-Allow-Headers', options.headers

        if 'OPTIONS' == req.method
          res.send(200);
        else
          next()

    winston.info "Enabled Cross-Origin-Resource-Sharing (CORS)"
    winston.info "\tAllow-Origin: #{options.origin}"
    winston.info "\tAllow-Methods: #{options.methods}"
    winston.info "\tAllow-Headers: #{options.headers}"

module.exports = CorsSupport
