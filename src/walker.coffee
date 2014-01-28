inheritHeaders = require './inherit-headers'
inheritParameters = require './inherit-parameters'
expandUriTemplateWithParameters = require './expand-uri-template-with-parameters'
exampleToHttpPayloadPair = require './example-to-http-payload-pair'

ut = require 'uri-template'

walker = (app, resourceGroups) ->

  sendResponse = (response) ->
    buildResponse = (req,res) ->
      for header, value of response.headers
            res.setHeader header, value['value']
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
            response = payload['pair']['response']

            responses.push {
              method: action.method
              path: path
              response: response
            }

  #sort routes
  responses.sort (a,b) ->
    if (a.path > b.path)
       return -1
    if (a.path < b.path)
      return 1
    return 0

  console.log responses.map (response) ->
    response.path

  for response in responses
    switch response.method
      when 'GET'
        app.get response.path, sendResponse(response.response)
      when 'POST'
        app.post response.path, sendResponse(response.response)
      when 'PUT'
        app.put response.path, sendResponse(response.response)
      when 'DELETE'
        app.delete response.path, sendResponse(response.response)
      when 'PATCH'
        app.patch response.path, sendResponse(response.response)



module.exports = walker
