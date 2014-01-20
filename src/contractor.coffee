fs = require 'fs'

protagonist = require 'protagonist'
express = require 'express'

walker = require './walker'

contractor = (configuration) ->
    protagonist = configuration['protagonist'] if configuration['protagonist']
    blueprintPath = configuration['blueprintPath'] if configuration['blueprintPath']

    if not blueprintPath?
      throw new Error "No blueprint path provided."

    try
      data = fs.readFileSync blueprintPath, 'utf8'
    catch e
      throw e

    # Get JSON representation of the blueprint file
    ast_json = ""
    protagonist.parse data,  (error, result) ->
      if error? then throw error
      ast_json = result.ast

      app = express()

      # Walk AST, add routes to app
      try
        walker app, ast_json['resourceGroups']
      catch error
        throw error

      # start server
      app.listen( if configuration?.options?.port? then configuration.options.port else 3000)

module.exports = contractor
