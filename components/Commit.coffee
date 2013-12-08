noflo = require 'noflo'

class Commit extends noflo.Component
  constructor: ->
    @transaction = null
    @message = null
    @inPorts =
      transaction: new noflo.Port 'object'
      message: new noflo.Port 'string'

    @inPorts.transaction.on 'data', (@transaction) =>
      do @commit
    @inPorts.message.on 'data', (@message) =>
      do @commit

  commit: ->
    return unless @transaction and @message
    @transaction.commit @message
    @transaction = null
    @message = null

exports.getComponent = -> new Commit
