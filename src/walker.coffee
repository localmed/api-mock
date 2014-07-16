inheritHeaders = require './inherit-headers'
inheritParameters = require './inherit-parameters'
expandUriTemplateWithParameters = require './expand-uri-template-with-parameters'
exampleToHttpPayloadPair = require './example-to-http-payload-pair'

ut = require 'uri-template'

walker = (app, resourceGroups) ->

  sendResponse = (responses) ->
    (req, res) ->

      # default response
      response = responses[Object.keys(responses)[0]]

      # try to find matching response based on PREFER header
      if req.headers['prefer']
        if responses[req.headers['prefer']]
          response = responses[req.headers['prefer']]
        else
          console.warn("[#{req.url}] Preferrered response #{req.headers['prefer']} not found. Falling back to #{response.status}")

      for header, value of response.headers
        headerName = value['name']
        headerValue = value['value']
        res.setHeader headerName, headerValue
      res.setHeader 'Content-Length', Buffer.byteLength(response.body)
      res.send response.status, response.body

  responses = []

  for group in resourceGroups
    for resource in group['resources']
      for action  in resource['actions']

        # headers and parameters can be specified higher up in the ast and inherited
        action['headers'] = inheritHeaders action['headers'], resource['headers']
        action['parameters'] = inheritParameters action['parameters'], resource['parameters']

        if resource['uriTemplate']?
          path = resource['uriTemplate'].split('{?')[0].replace(new RegExp("}","g"), "").replace(new RegExp("{","g"), ":")

          # the routes are generated
          for example in action['examples']
            payload = exampleToHttpPayloadPair example, action['headers']

            for warning in payload['warnings']
              console.warn("[#{path}] #{warning}")

            for error in payload['errors']
              console.error("[#{path}] #{error}")

            responses.push {
              method: action.method
              path: path
              responses: payload['pair']['responses']
            }

  #sort routes
  responses.sort (a,b) ->
    if (a.path > b.path)
       return -1
    if (a.path < b.path)
      return 1
    return 0

  for response in responses
    switch response.method
      when 'GET'
        app.get response.path, sendResponse(response.responses)
      when 'POST'
        app.post response.path, sendResponse(response.responses)
      when 'PUT'
        app.put response.path, sendResponse(response.responses)
      when 'DELETE'
        app.delete response.path, sendResponse(response.responses)
      when 'PATCH'
        app.patch response.path, sendResponse(response.responses)



module.exports = walker
