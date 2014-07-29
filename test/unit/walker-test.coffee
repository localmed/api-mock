{assert} = require 'chai'
sinon = require 'sinon'
nock = require 'nock'
proxyquire = require('proxyquire').noCallThru()
request = require 'supertest'

utStub = require 'uri-template'
winstonStub = require 'winston'
express = require 'express'
exampleToHttpPayloadPairStub = sinon.stub()

walker = proxyquire '../../src/walker', {
  'uri-template': utStub,
  'winston': winstonStub,
  './example-to-http-payload-pair': exampleToHttpPayloadPairStub
}


describe 'walker', () ->

  app = express()
  resourceGroups = []

  describe 'with actions with uri templates', () ->

    payload = {}

    beforeEach () ->
      sinon.stub app, 'get', (path, callback) ->
        # callback()
      sinon.stub app, 'post', (path, callback) ->
        # callback()
      sinon.stub app, 'put', (path, callback) ->
        # callback()
      sinon.stub app, 'delete', (path, callback) ->
        # callback()
      sinon.stub app, 'patch', (path, callback) ->
        # callback()
      payload =
        warnings: []
        errors: []
        pair:
          request:
            body: ''
            headers: {}
          responses:
            '200':
              body: '[\n  {\n    "type": "bulldozer",\n    "name": "willy"\n  }\n]\n',
              headers: [ { name: 'Content-Type', value: 'application/json' } ],
              status: '200'
            '404':
              body: '[\n  {\n    "error": "bad request" }\n]\n',
              headers: [ { name: 'Content-Type', value: 'application/json' } ],
              status: '404'
      exampleToHttpPayloadPairStub.returns(payload)
      resourceGroups = [
        {
          name: 'Machines',
          description: '',
          resources: [
            {
              name: 'Machines collection',
              description: '',
              uriTemplate: '/machines',
              model: {},
              parameters: [],
              actions: [
                {
                  name: 'Get Machines',
                  description: '',
                  method: 'GET',
                  parameters: [],
                  examples: [
                    {
                      name: '',
                      description: '',
                      requests: [],
                      responses: [
                        {
                          name: '200',
                          description: '',
                          headers: [
                            {
                              name: 'Content-Type',
                              value: 'application/json'
                            }
                          ],
                          body: '[\n  {\n    "type": "bulldozer",\n    "name": "willy"\n  }\n]\n',
                          schema: ''
                        }
                      ]
                    }
                  ]
                }
              ]
            },
            {
              name: 'Machines creation',
              description: '',
              uriTemplate: '/machines',
              model: {},
              parameters: [],
              actions: [
                {
                  name: 'Create Machines',
                  description: '',
                  method: 'POST',
                  parameters: [],
                  examples: [
                    {
                      name: '',
                      description: '',
                      requests: [],
                      responses: [
                        {
                          name: '201',
                          description: '',
                          headers: [
                            {
                              name: 'Content-Type',
                              value: 'application/json'
                            }
                          ],
                          body: '[\n  {\n    "type": "bulldozer",\n    "name": "willy"\n  }\n]\n',
                          schema: ''
                        }
                      ]
                    }
                  ]
                },
              ]
            },
            {
              name: 'BadMachines deletion',
              description: '',
              uriTemplate: '/bad-machines',
              model: {},
              parameters: [],
              actions: [
                {
                  name: 'Delete BadMachines',
                  description: '',
                  method: 'DELETE',
                  parameters: [],
                  examples: [
                    {
                      name: '',
                      description: '',
                      requests: [],
                      responses: [
                        {
                          name: '201',
                          description: '',
                          headers: [
                            {
                              name: 'Content-Type',
                              value: 'application/json'
                            }
                          ],
                          body: '[\n  {\n    "type": "badbulldozer",\n    "name": "evilly"\n  }\n]\n',
                          schema: ''
                        }
                      ]
                    }
                  ]
                },
              ]
            },
            {
              name: 'GoodMachines Update',
              description: '',
              uriTemplate: '/good-machines',
              model: {},
              parameters: [],
              actions: [
                {
                  name: 'Create GoodMachines',
                  description: '',
                  method: 'PUT',
                  parameters: [],
                  examples: [
                    {
                      name: '',
                      description: '',
                      requests: [],
                      responses: [
                        {
                          name: '200',
                          description: '',
                          headers: [
                            {
                              name: 'Content-Type',
                              value: 'application/json'
                            }
                          ],
                          body: '[\n  {\n    "type": "goodbulldozer",\n    "name": "goodly"\n  }\n]\n',
                          schema: ''
                        }
                      ]
                    }
                  ]
                },
              ]
            },
            {
              name: 'GoodMachines Patch',
              description: '',
              uriTemplate: '/good-machines',
              model: {},
              parameters: [],
              actions: [
                {
                  name: 'Create GoodMachines',
                  description: '',
                  method: 'PATCH',
                  parameters: [],
                  examples: [
                    {
                      name: '',
                      description: '',
                      requests: [],
                      responses: [
                        {
                          name: '200',
                          description: '',
                          headers: [
                            {
                              name: 'Content-Type',
                              value: 'application/json'
                            }
                          ],
                          body: '[\n  {\n    "type": "goodbulldozer",\n    "name": "goodly"\n  }\n]\n',
                          schema: ''
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]

    afterEach ()->
      app.get.restore()
      app.post.restore()
      app.put.restore()
      app.delete.restore()
      app.patch.restore()

    it 'should set the routes on the app', ()->
      walker(app, resourceGroups)
      assert.ok app.get.called
      assert.ok app.post.called
      assert.ok app.put.called
      assert.ok app.delete.called
      assert.ok app.patch.called

    describe 'when there are problems converting the payload', ()->

      beforeEach ()->
        sinon.stub winstonStub, 'warn'
        sinon.stub winstonStub, 'error'
        payload.warnings =  [
            "Minor problem"
          ]
        payload.errors = [
            "Major problem"
          ]
        exampleToHttpPayloadPairStub.returns(payload)


      afterEach ()->
        payload.warnings = []
        payload.errors = []
        winstonStub.warn.restore()
        winstonStub.error.restore()
        exampleToHttpPayloadPairStub.reset()

      it 'should report warnings and errors', ()->
        walker(app, resourceGroups)
        assert.ok winstonStub.warn.called
        assert.ok winstonStub.error.called

    describe 'when sending a response', ()->

      beforeEach () ->
        app.get.restore()

      afterEach () ->
        sinon.stub app, 'get', () -> {}

      it 'should send successfully', (done) ->
        walker(app, resourceGroups)
        request(app)
          .get('/machines')
          .set('Accept', 'application/json')
          .expect('Content-Type', /json/)
          .expect(200, done)

      describe 'when a specific response is specified with a prefer header', ()->

        it 'should send the correct response', (done) ->
          walker(app, resourceGroups)
          request(app)
            .get('/machines')
            .set('Accept', 'application/json')
            .set('Prefer', '404')
            .expect('Content-Type', /json/)
            .expect(404, done)

        describe 'and prefered response does not exist', () ->

          beforeEach ()->
            sinon.stub winstonStub, 'warn'

          afterEach ()->
            winstonStub.warn.restore()

          it 'should display a warning', (done) ->
            walker(app, resourceGroups)
            request(app)
              .get('/machines')
              .set('Accept', 'application/json')
              .set('Prefer', '422')
              .end (err, res) ->
                assert.ok winstonStub.warn.called
                done()



