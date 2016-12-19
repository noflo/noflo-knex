noflo = require 'noflo'
knex = require 'knex'

class Connect extends noflo.Component
  constructor: ->
    @provider = null
    @configuration = null
    @inPorts =
      provider: new noflo.Port 'string'
      configuration: new noflo.Port 'object'
    @outPorts =
      connection: new noflo.Port 'object'

    @inPorts.provider.on 'data', (@provider) =>
      do @connectDb
    @inPorts.configuration.on 'data', (@configuration) =>
      do @connectDb

  connectDb: ->
    return unless @provider and @configuration
    connection = new knex
      client: @provider
      connection: @configuration
      useNullAsDefault: true
    @outPorts.connection.send connection
    @outPorts.connection.disconnect()
    @provider = null
    @configuration = null

exports.getComponent = -> new Connect
