Common = require './Common'
CoAP   = require './CoAP'

class Group extends Common

  @property 'on',
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
