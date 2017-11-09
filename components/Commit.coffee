noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'transaction',
    datatype: 'object'
  c.inPorts.add 'message',
    datatype: 'string'
  c.outPorts.add 'out',
    datatype: 'bang'
  c.forwardBrackets =
    transaction: ['out']
  c.process (input, output) ->
    return unless input.hasData 'transaction', 'message'
    [transaction, message] = input.getData 'transaction', 'message'
    transaction.commit message
    output.sendDone
      out: true
    return
