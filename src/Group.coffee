Common = require './Common'
IsEqual = require 'deep-equal'

class Group extends Common

  startPoll: ->
    console.log "Starting group poll: #{@id}: #{@name}"
    @coap.groupObserve @id, (response) =>
      response.code = response.code.toString()
      response.payload = response.payload.toString()
      console.log response
    .then (ans) ->
      console.log "ANS:", ans
    .catch (err) ->
      console.log 'ERROR', err
    

  @property 'ison',
    get: ->
      @raw[5850] is 1

  switch: (onoff) ->
    value = if onnoff then 1 else 0
    job = '5850': value
    @coap.updateGroup @id, job
    .then =>
      @raw[5850] = value
      @

  @property 'devices',
    get: ->
      @raw[9018][15002][9003]

  getDevices: ->
    Promise.all (@coap.device id for id in @devices)

module.exports = Group
