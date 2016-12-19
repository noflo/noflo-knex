noflo = require 'noflo'

class BeginTransaction extends noflo.Component
  constructor: ->
    @inPorts =
      connection: new noflo.Port 'object'
    @outPorts =
      transaction: new noflo.Port 'object'
      success: new noflo.Port 'string'
      error: new noflo.Port 'object'

    @inPorts.connection.on 'data', (db) =>
      db.transaction (t) =>
        @outPorts.transaction.send t
        @outPorts.transaction.disconnect()
      .then (commitMessage) =>
        return unless @outPorts.success.isAttached()
        @outPorts.success.send commitMessage
        @outPorts.success.disconnect()
      .catch (err) =>
        return unless @outPorts.error.isAttached()
        @outPorts.error.send err
        @outPorts.error.disconnect()

exports.getComponent = -> new BeginTransaction
