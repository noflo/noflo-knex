noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'connection',
    datatype: 'object'
  c.outPorts.add 'transaction',
    datatype: 'object'
  c.outPorts.add 'success',
    datatype: 'string'
  c.outPorts.add 'error',
    datatype: 'object'
  c.forwardBrackets =
    connection: ['transaction', 'success', 'error']
  c.process (input, output) ->
    return unless input.hasData 'connection'
    db = input.getData 'connection'
    db.transaction (t) ->
      output.send
        transaction: t
    .then (commitMessage) ->
      output.send
        success: commitMessage
      output.done()
    .catch (err) ->
      output.done err
    return
