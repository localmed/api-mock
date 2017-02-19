{assert} = require 'chai'
sinon = require 'sinon'
nock = require 'nock'
proxyquire = require('proxyquire').noCallThru()

fsStub = require 'fs'
protagonistStub = require 'protagonist'
expressStub = require 'express'
walkerStub = sinon.stub()
SslSupportStub = sinon.stub()
CorsSupportStub = sinon.stub()

ApiMock = proxyquire '../../src/api-mock', {
  'fs': fsStub
  'protagonist': protagonistStub
  'express': expressStub,
  './walker': walkerStub
  './ssl-support': SslSupportStub
  './cors-support': CorsSupportStub
}


describe 'ApiMock class', () ->

  describe 'constructor', () ->

    configuration = {}

    beforeEach ()->
      SslSupportStub.reset()
      CorsSupportStub.reset()

    describe 'with valid configuration', () ->

      beforeEach ()->
        configuration =
          blueprintPath: './test/fixtures/single-get.apib',
          options:
            port: 3005

      it 'should copy configuration on creation', () ->
        api_mock = new ApiMock(configuration)
        assert.ok api_mock.configuration.options.port == 3005

      describe 'with ssl support enabled', () ->

        beforeEach ()->
          configuration =
            blueprintPath: './test/fixtures/single-get.apib',
            options:
              'ssl-enable': true
              'ssl-port': 3006
              'ssl-host': 'localhost'
              'ssl-cert': 'cert'
              'ssl-key': 'key'

        it 'should enable ssl', () ->
          api_mock = new ApiMock(configuration)
          assert.ok SslSupportStub.called

      describe 'with cors support disabled', () ->

        beforeEach ()->
          configuration =
            blueprintPath: './test/fixtures/single-get.apib',
            options:
              port: 3005
              'cors-disable': true


        it 'should disable cors', () ->
          api_mock = new ApiMock(configuration)
          assert.ok api_mock.configuration.options.port == 3005
          assert.notOk CorsSupportStub.called

    describe 'with invalid configuration', () ->

      beforeEach ()->
        configuration =
          options:
            port: 3005

      it 'should throw an error', () ->
        new_api_mock = () ->
          api_mock = new ApiMock(configuration)
        assert.throws new_api_mock, 'No blueprint path provided.'

  describe 'run()', () ->

    api_mock = {}
    configuration = {}

    beforeEach () ->
      configuration =
        blueprintPath: './test/fixtures/single-get.apib',
        options:
          port: 3005
      api_mock = new ApiMock(configuration)

    describe 'with existing blueprint file', () ->

      describe 'with valid blueprint', () ->

        describe 'with valid routes', () ->

          beforeEach () ->
            sinon.stub api_mock.app, 'listen', (port)->
              {}
            sinon.stub fsStub, 'readFileSync', (path, enc) ->
              {}
            sinon.stub protagonistStub, 'parse', (data, type, callback) ->
              result =
                ast:
                  resourceGroups: [
                    'resource',
                    'resource',
                    'resource'
                  ]
              callback(null, result)

          afterEach () ->
            api_mock.app.listen.restore()
            fsStub.readFileSync.restore()
            protagonistStub.parse.restore()
            walkerStub.reset()

          it 'should add routes to the app', () ->
            api_mock.run()
            assert.ok walkerStub.called

          it 'should start the server', () ->
            api_mock.run()
            assert.ok api_mock.app.listen.called

        describe 'with error while listening', () ->

          beforeEach () ->
            sinon.stub api_mock.app, 'listen', (port)->
              throw new Error('Error starting server')
            sinon.stub fsStub, 'readFileSync', (path, enc) ->
              {}
            sinon.stub protagonistStub, 'parse', (data, type, callback) ->
              result =
                ast:
                  resourceGroups: [
                    'resource',
                    'resource',
                    'resource'
                  ]
              callback(null, result)

          afterEach () ->
            api_mock.app.listen.restore()
            fsStub.readFileSync.restore()
            protagonistStub.parse.restore()

          it 'should not throw an error', ()->
            assert.doesNotThrow api_mock.run, 'Error starting server'

        describe 'with invalid routes', () ->

          beforeEach () ->
            walkerStub.throws(new Error('Error walking routes'))
            sinon.stub fsStub, 'readFileSync', (path, enc) ->
              {}
            sinon.stub protagonistStub, 'parse', (data, type, callback) ->
              result =
                ast:
                  resourceGroups: [
                    'resource',
                    'resource',
                    'resource'
                  ]
              callback(null, result)

          afterEach () ->
            walkerStub.reset()
            fsStub.readFileSync.restore()
            protagonistStub.parse.restore()

          it 'should throw an error', () ->
            assert.throws api_mock.run, 'Error walking routes'


      describe 'with error parsing blueprint', () ->

        beforeEach () ->
          sinon.stub fsStub, 'readFileSync', (path, enc) ->
            {}
          sinon.stub protagonistStub, 'parse', (data, type, callback) ->
            callback(new Error('Error parsing blueprint'), null)

        afterEach () ->
          fsStub.readFileSync.restore()
          protagonistStub.parse.restore()

        it 'it should throw an error', () ->
          assert.throws api_mock.run, 'Error parsing blueprint'

    describe 'with error reading blueprint', () ->

      beforeEach () ->
        sinon.stub fsStub, 'readFileSync', (path, enc) ->
          throw new Error('Error reading file')

      afterEach () ->
        fsStub.readFileSync.restore()

      it 'should throw an error', ()->
        assert.throws api_mock.run, 'Error reading file'
