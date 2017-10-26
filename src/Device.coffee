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

  @property 'colour',
    get: -> @raw[3311]?[0][5706]

  @property 'color',
    get: -> @colour

  @property 'brightness',
    get: ->
      bright = @raw[3311]?[0][5851]
      Math.round bright * 100 / 254 if bright?

module.exports = Device
