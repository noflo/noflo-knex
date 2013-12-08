noflo = require 'noflo'
chai = require 'chai'
Connect = require '../components/Connect.coffee'

describe 'Connect component', ->
  c = null
  provider = null
  configuration = null
  connection = null
  beforeEach (done) ->
    c = Connect.getComponent()
    provider = noflo.internalSocket.createSocket()
    configuration = noflo.internalSocket.createSocket()
    connection = noflo.internalSocket.createSocket()
    c.inPorts.provider.attach provider
    c.inPorts.configuration.attach configuration
    c.outPorts.connection.attach connection
    done()

  describe 'opening a connection', ->
    it 'should make a connection we can create tables on', (done) ->
      connection.on 'data', (data) ->
        chai.expect(data.schema).to.be.an 'object'
        data.schema.createTable 'connect', (t) ->
          t.increments('id').primary()
          return
        .then ->
          done()

      provider.send 'sqlite3'
      configuration.send
        filename: ':memory:'
