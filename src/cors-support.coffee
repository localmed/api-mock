class CorsSupport
  constructor: (app) ->

    options =
      origin: '*'
      methods: 'GET, PUT, POST, PATCH, DELETE, TRACE, OPTIONS'
      headers: 'Origin, X-Requested-With, Content-Type, Accept, Authorization, Referer, Prefer'

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

    console.log(
      "Enabled Cross-Origin-Resource-Sharing (CORS)\n" + \
      "\tAllow-Origin: #{options.origin}\n" + \
      "\tAllow-Methods: #{options.methods}\n" + \
      "\tAllow-Headers: #{options.headers}"
    )

module.exports = CorsSupport
