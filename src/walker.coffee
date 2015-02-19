inheritHeaders = require './inherit-headers'
inheritParameters = require './inherit-parameters'
expandUriTemplateWithParameters = require './expand-uri-template-with-parameters'
exampleToHttpPayloadPair = require './example-to-http-payload-pair'
buildExpressHandler = require './build-express-handler'

ut = require 'uri-template'
winston = require 'winston'

walker = (app, resourceGroups) ->

  responses = {}

  for group in resourceGroups
    for resource in group['resources']
      for action  in resource['actions']

        # headers and parameters can be specified higher up in the ast and inherited
        action['headers'] = inheritHeaders action['headers'], resource['headers']
        action['parameters'] = inheritParameters action['parameters'], resource['parameters']

        if resource['uriTemplate']?
          # removes query parameters, and converts uri template params into what express expects
          # e.g. /templates/{templateId}/?status=good would become /templates/:templateId/
          # TODO: replate with uri template processing
          path = resource['uriTemplate'].split('{?')[0].replace(new RegExp("}","g"), "").replace(new RegExp("{","g"), ":")

          # the routes are generated
          for example in action['examples']
            payload = exampleToHttpPayloadPair example, action['headers']

            for warning in payload['warnings']
              winston.warn("[#{path}] #{warning}")

            for error in payload['errors']
              winston.error("[#{path}] #{error}")

            if !responses[path]?
              responses[path] = {}

            actionMethod = action.method.toLowerCase()

            if !responses[path][actionMethod]?
              responses[path][actionMethod] = []

            responses[path][actionMethod].push {
              request: payload.pair.request
              responses: payload.pair.responses
            }

  paths = Object.keys responses

  #sort routes
  paths.sort (a,b) ->
    if (a > b)
       return -1
    if (a <= b)
      return 1

  for path in paths
    pathMethods = responses[path]
    for method, payloads of pathMethods
      if app[method]?
        app[method](path, buildExpressHandler(payloads))

module.exports = walker
