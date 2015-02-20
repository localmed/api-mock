{assert} = require 'chai'
sinon = require 'sinon'
proxyquire = require 'proxyquire'

winstonStub = require 'winston'

expressHandler = proxyquire '../../src/build-express-handler', {
  'winston': winstonStub
}

describe 'build-express-handler', () ->
  describe 'body comparison', () ->
    it 'should correctly match two empty strings', () ->
      assert.isTrue expressHandler.comparePayloads(null, null)
    it 'should correctly match two differing strings', () ->
      assert.isFalse expressHandler.comparePayloads('foo', 'bar')
    it 'should correctly match a null expectation with a body containing data', () ->
      assert.isTrue expressHandler.comparePayloads(null, {"foo": "bar"})
    it 'should identify a non-matching body', () ->
      assert.isFalse expressHandler.comparePayloads({"foo":"4"}, {"foo":"3"})
    it 'should be lenient on types for non-objects', () ->
      assert.isTrue expressHandler.comparePayloads({"foo":4}, {"foo":"4"}), "Comparison works: integer type is typecasted to string"
    it 'should correctly recurse for deep-match', () ->
      sinon.spy expressHandler, "comparePayloads"
      assert.isFalse expressHandler.comparePayloads({"foo":{"bar":"baz"}}, {"foo":{"barry":"baz"}}), "Comparison failed: inside key not matched"
      assert.isTrue expressHandler.comparePayloads.calledWith({"foo":{"bar":"baz"}}, {"foo":{"barry":"baz"}}), "Initial call happened"
      assert.isTrue expressHandler.comparePayloads.calledWith({"bar":"baz"}, {"barry":"baz"}), "Second recursion happened"
    it 'should not match null to a valid object', () ->
      assert.isFalse expressHandler.comparePayloads({"foo":{"bar":"baz"}}, null)

  describe 'matchBody', () ->

    it 'should check for payload headers before parsing json', () ->
      body = JSON.stringify {'foo':'bar'}
      headers = {'content-type': 'application/json'}
      expressHandler.matchBody {'body': body, 'headers': headers}, body, headers
      assert.isTrue expressHandler.comparePayloads.calledWith('bar', 'bar')

    it 'should check the query object', () ->
      body = {'foo': 'bar'}
      headers = {}
      expressHandler.matchBody {'query': body, 'body': ''}, body, {}
      console.log expressHandler.comparePayloads
      assert.isTrue expressHandler.comparePayloads.calledWith(body, body)

    it 'should also add parameter values', () ->
      body = {'foo': 'bar'}
      expected = {'foo2':'bar2'}
      expressHandler.matchBody {'query': body, 'body': '', 'params': {'foo2': 'bar2'}}, {'foo': 'bar', 'foo2': 'bar2'}, {}
      console.log expressHandler.comparePayloads
      assert.isTrue expressHandler.comparePayloads.calledWith('bar2', 'bar2')

    it 'should fallback to a literal match on malformatted bodies', () ->
      sinon.stub winstonStub, 'warn', () ->
      body = '{"foo":bar}'
      headers = {'content-type': 'application/json'}
      assert.isTrue expressHandler.matchBody({'body':body, 'headers': headers}, body, headers)
      assert.isTrue winstonStub.warn.calledTwice
      winstonStub.warn.restore()

  describe 'matcher', () ->
    it 'should fallback to the last response if nothing matches', (done) ->
      request = {
        headers: {}
        body: ""
      }
      payloads = [
        {
          request: {
            headers: {
              'content-type': 'application/json'
            }
          },
          response: {
            status: 200,
            body: 'foo'
          }
        }
      ]
      o = sinon.stub(expressHandler, "respond", (o1, o2, payload) ->
        assert.equal payload.response.status, 200
        assert.equal payload.response.body, 'foo'
        done()
      );
      s = expressHandler payloads
      foo = {}
      s request, foo
      assert.isTrue o.calledOnce
      o.restore()
      
    it 'should properly attempt to match a body that contains json', () ->
      headers = {
        "content-type": "application/json"
      }
      request = {
        headers: headers
        body: "{\"foo\":2}"
      }
      payloads = [
        {
          "request": {
            "body": {
              "foo": 3
            }
          }
        },
        {
          "request": {
            "body": {
              "foo": 2
            },
            "headers": {
              "content-type": "application/json+uml"
            }
          }
        }
        {
          "response": {
            "body": "foo",
            "headers": {
              "content-type": "text-plain"
            }
          }
        }
      ]
      o = sinon.stub(expressHandler, "respond", () ->);
      s = expressHandler payloads
      foo = {}
      s request, foo
      assert.isTrue o.calledOnce
      o.restore()
      
