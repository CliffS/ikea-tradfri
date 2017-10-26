Common = require './Common'
CoAP   = require './CoAP'

class Group extends Common

  constructor: (raw, @coap) ->
    super raw

  @property 'on',
    get: ->
      @raw[5850] is 1

  @property 'devices',
    get: ->
      @raw[9018][15002][9003]

  getDevices: ->
    Promise.all (@coap.device id for id in @devices)

module.exports = Group
