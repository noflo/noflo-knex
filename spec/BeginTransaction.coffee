noflo = require 'noflo'
chai = require 'chai' unless chai
BeginTransaction = require '../components/BeginTransaction.coffee'
Knex = require 'knex'
conn = new Knex
  client: 'sqlite3'
  connection:
    filename: ':memory:'

describe 'BeginTransaction component', ->
  c = null
  connection = null
  transaction = null
  success = null
  error = null
  trans = null
  prepareComponent = (done) ->
    c = BeginTransaction.getComponent()
    connection = noflo.internalSocket.createSocket()
    transaction = noflo.internalSocket.createSocket()
    success = noflo.internalSocket.createSocket()
    error = noflo.internalSocket.createSocket()
    c.inPorts.connection.attach connection
    c.outPorts.transaction.attach transaction
    c.outPorts.success.attach success
    c.outPorts.error.attach error
    done()
  before (done) ->
    conn.schema.hasTable('begintransaction').then (exists) ->
      return prepareComponent done if exists
      conn.schema.createTable 'begintransaction', (t) ->
        t.increments('id').primary()
        t.string 'name'
        return
      .then ->
        prepareComponent done
    return

  describe 'for correct transaction', ->
    it 'should be able to start a transaction', (done) ->
      transaction.once 'data', (t) ->
        chai.expect(t).to.be.an 'object'
        trans = t
        done()
      connection.send conn
    it 'should allow doing DB operations inside the transaction', (done) ->
      conn('begintransaction')
      .transacting(trans)
      .insert
        name: 'Foo Bar'
      .then (rows) ->
        chai.expect(rows).to.be.an 'array'
        chai.expect(rows[0]).to.equal 1
        done()
      return
    describe 'on commit', ->
      it 'should call success', (done) ->
        success.once 'data', (data) ->
          chai.expect(data).to.equal 'Hello world'
          done()
        trans.commit 'Hello world'
        trans = null
      it 'the data should be available for query', (done) ->
        conn('begintransaction')
        .select('name', 'id')
        .then (begintransaction) ->
          chai.expect(begintransaction).to.be.an 'array'
          chai.expect(begintransaction.length).to.equal 1
          chai.expect(begintransaction[0]).to.be.an 'object'
          chai.expect(begintransaction[0].name).to.equal 'Foo Bar'
          done()
        return

  describe 'for failing transaction', ->
    it 'should be able to start a transaction', (done) ->
      transaction.once 'data', (t) ->
        chai.expect(t).to.be.an 'object'
        trans = t
        done()
      connection.send conn
    it 'should allow doing DB operations inside the transaction', (done) ->
      conn('begintransaction')
      .transacting(trans)
      .insert
        name: 'Bar Baz'
      .then (rows) ->
        chai.expect(rows).to.be.an 'array'
        chai.expect(rows[0]).to.equal 2
        done()
      return
    describe 'on rollback', ->
      it 'should call error', (done) ->
        error.once 'data', (data) ->
          chai.expect(data).to.be.instanceof Error
          chai.expect(data.message).to.equal 'We roll'
          done()
        trans.rollback new Error 'We roll'
      it 'the data should not be available for query', (done) ->
        conn('begintransaction')
        .select('name', 'id')
        .then (begintransaction) ->
          chai.expect(begintransaction).to.be.an 'array'
          chai.expect(begintransaction.length).to.equal 1
          chai.expect(begintransaction[0]).to.be.an 'object'
          chai.expect(begintransaction[0].name).to.equal 'Foo Bar'
          done()
        return
