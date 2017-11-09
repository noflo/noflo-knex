noflo = require 'noflo'
knex = require 'knex'

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'provider',
    datatype: 'string'
  c.inPorts.add 'configuration',
    datatype: 'object'
  c.outPorts.add 'connection',
    datatype: 'object'
  c.outPorts.add 'error',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'provider', 'configuration'
    [provider, config] = input.getData 'provider', 'configuration'
    connection = new knex
      client: provider
      connection: config
      useNullAsDefault: true
    output.sendDone
      connection: connection
