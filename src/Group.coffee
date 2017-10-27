Common = require './Common'
CoAP   = require './CoAP'
IsEqual = require 'deep-equal'

INTERVAL = 1000 / 5     # 5 times a second

class Group extends Common

  startPoll: ->
    console.log "Starting group poll: #{@id}"
    @polling = setInterval =>
      @coap.groupRaw @id
      .then (raw) =>
        unless IsEqual @raw, raw
          @emit 'changed',
            ison: [@ison, raw[5850] is 1]
          @raw = raw
      .catch (err) =>
        console.log "ERROR in #{@id}", err.toString()
    , INTERVAL

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
