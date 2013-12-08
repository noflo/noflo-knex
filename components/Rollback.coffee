noflo = require 'noflo'

class Rollback extends noflo.Component
  constructor: ->
    @transaction = null
    @message = null
    @inPorts =
      transaction: new noflo.Port 'object'
      message: new noflo.Port 'all'

    @inPorts.transaction.on 'data', (@transaction) =>
      do @commit
    @inPorts.message.on 'data', (@message) =>
      do @commit

  commit: ->
    return unless @transaction and @message
    @transaction.rollback @message
    @transaction = null
    @message = null

exports.getComponent = -> new Rollback
