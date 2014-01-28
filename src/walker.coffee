inheritHeaders = require './inherit-headers'
inheritParameters = require './inherit-parameters'
expandUriTemplateWithParameters = require './expand-uri-template-with-parameters'
exampleToHttpPayloadPair = require './example-to-http-payload-pair'

walker = (app, resourceGroups) ->

  sendResponse = (response) ->
    buildResponse = (req,res) ->
      for header, value of response.headers
            res.setHeader header, value['value']
      res.setHeader 'Content-Length', Buffer.byteLength(response.body)
      res.send response.status, response.body

  for group in resourceGroups
    for resource in group['resources']
      for action  in resource['actions']

        # headers and parameters can be specified higher up in the ast and inherited
        action['headers'] = inheritHeaders action['headers'], resource['headers']
        action['parameters'] = inheritParameters action['parameters'], resource['parameters']

        if resource['uriTemplate']?
          path = resource['uriTemplate'].split('{?')[0].replace(new RegExp("}","g"), "").replace(new RegExp("{","g"), ":")

          # the tests are generated from the example responses from the ast
          for example in action['examples']
            payload = exampleToHttpPayloadPair example, action['headers']
            response = payload['pair']['response']

            switch action.method
              when 'GET'
                app.get path, sendResponse(response)
              when 'POST'
                app.post path, sendResponse(response)
              when 'PUT'
                app.put path, sendResponse(response)
              when 'DELETE'
                app.delete path, sendResponse(response)
              when 'PATCH'
                app.patch path, sendResponse(response)



module.exports = walker
