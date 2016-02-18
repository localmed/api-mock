fs = require 'fs'

protagonist = require 'protagonist'
express = require 'express'
walker = require './walker'
SslSupport = require './ssl-support'
CorsSupport = require './cors-support'

class ApiMock
  constructor: (config) ->
    protagonist = config['protagonist'] if config['protagonist']
    express = config['express'] if config['express']
    @blueprintPath = config['blueprintPath'] if config['blueprintPath']

    if not @blueprintPath?
      throw new Error "No blueprint path provided."

    @configuration = config
    @app = express()

    if @configuration.options['ssl-enable']
      sslSupport = new SslSupport(
        @app,
            port: @configuration.options['ssl-port'],
            host: @configuration.options['ssl-host'],
            cert: @configuration.options['ssl-cert'],
            key: @configuration.options['ssl-key']
      )

    if !@configuration.options['cors-disable']
      corsSupport = new CorsSupport @app

  run: () ->
    app = @app

    try
      data = fs.readFileSync @blueprintPath, 'utf8'
    catch e
      throw e

    # Get JSON representation of the blueprint file
    ast_json = ""
    protagonist.parse data, {type: "ast"}, (error, result) =>
      if error? then throw error
      ast_json = result.ast

      # Walk AST, add routes to app
      try
        walker app, ast_json['resourceGroups']
      catch error
        throw error

      # start server
      try
        app.listen( if @configuration?.options?.port? then @configuration.options.port else 3000 )
      catch error


module.exports = ApiMock
