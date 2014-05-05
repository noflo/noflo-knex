noflo = require 'noflo'

class Rollback extends noflo.Component
  constructor: ->
    @transaction = null
    @message = null
    @inPorts =
      transaction: new noflo.Port 'object'
      message: new noflo.Port 'all'

    @inPorts.transaction.on 'data', (@transaction) =>
      do @rollback
    @inPorts.message.on 'data', (@message) =>
      do @rollback

  rollback: ->
    return unless @transaction and @message
    unless @message instanceof Error
      @message = new Error @message

    @transaction.rollback @message
    @transaction = null
    @message = null

exports.getComponent = -> new Rollback
