Accessory = require './Accessory'

class Blind extends Accessory

  # Add the 'property' definition here as we can't inherit from it
  @property: (name, accessors) ->
    Object.defineProperty @::, name, accessors

  constructor: (device) ->
    super device
    blind = device.blindList[0]
    @position   = blind.position
    @switchable = blind.isSwitchable
    @dimmable   =  blind.isDimmable

  operate: (obj, val) ->
    tradfri = @device.client
    await tradfri.operateBlind @device, obj, val

  open: ->
    @operate position: 100

  close: ->
    @operate position: 0

  setPosition: (pos) ->
    @operate position: pos

module.exports = Blind
