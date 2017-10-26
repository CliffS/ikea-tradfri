Common = require './Common'

class Device extends Common

  @property 'type',
    get: -> @raw[3][1]

  @property 'manufacturer',
    get: -> @raw[3][0]

  @property 'on',
    get: ->
      ison = @raw[3311]?[0][5850]
      ison is 1 if ison?

  switch: (onoff) ->
    value = if onoff then 1 else 0
    job =
      '3311': [
        '5850' : value
      ]
    @coap.updateDevice @id, job
    .then =>
      @raw[3311]?[0][5850] = value
      @

  @property 'colour',
    get: -> @raw[3311]?[0][5706]

  @property 'color',
    get: -> @colour

  @property 'brightness',
    get: ->
      bright = @raw[3311]?[0][5851]
      Math.round bright * 100 / 254 if bright?

module.exports = Device
