winston = require 'winston'

comparePayloads = (expected, actual) ->
  if !expected
    return true

  if typeof expected == 'object'
    if typeof actual != 'object' or actual == null
      return false
    for k, v of expected
      if !actual[k] or !actual.hasOwnProperty(k)
        return false

      if !module.exports.comparePayloads(v, actual[k])
        return false
  else
    if expected.toString() != actual.toString()
      return false
  return true

respond = (requestObject, responseObject, payload) ->

  respondWithPayload = (response) ->
    for header, value of response.headers
      responseObject.setHeader value['name'], value['value']
    responseObject.setHeader 'Content-Length', Buffer.byteLength(response.body)
    return responseObject.send status, response.body

  for status, response of payload.responses
    if "prefer" of requestObject.headers
      if requestObject.headers["prefer"] != status
        continue
    return respondWithPayload(response)

  keys = Object.keys(payload.responses)
  winston.warn "[#{payload.path}] Preferred response #{requestObject.headers['prefer']} not found. Falling back to #{keys[0]}"
  return respondWithPayload(payload.responses[keys[0]])

matchBody = (requestObject, body, headers) ->
  if headers and headers["content-type"] == "application/json"
    try
      body = JSON.parse body
    catch e
      winston.warn "Could not parse body JSON"

  try
    requestPayload = requestObject.body.toString()
    if requestPayload.length == 0 or requestObject.headers['content-type'] != 'application/json'
      requestPayload = requestObject.query
    else
      requestPayload = JSON.parse requestPayload

    # Done parsing the request payload. Let's have some fun.
    return module.exports.comparePayloads(body, requestPayload)
  catch e
    # Literal match on body
    winston.warn "Could not parse input body"
    return body.toString() == requestObject.body.toString()

matchHeaders = (requestObject, headers) ->
  return comparePayloads(headers, requestObject.headers)

buildExpressHandler = (payloads) ->
  return (request, response) ->
    l = payloads.length
    for payload in payloads
      if payload.request and payload.request.body and !matchBody(request, payload.request.body, payload.request.headers)
        continue
      if payload.request and payload.request.headers and !matchHeaders(request, payload.request.headers)
        continue
      return buildExpressHandler.respond(request, response, payload)
    return buildExpressHandler.respond(request, response, payloads[l - 1])

buildExpressHandler.comparePayloads = comparePayloads
buildExpressHandler.matchBody = matchBody
buildExpressHandler.matchHeaders = matchHeaders
buildExpressHandler.respond = respond
module.exports = buildExpressHandler

