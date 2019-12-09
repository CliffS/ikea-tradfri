Accessory = require './Accessory'

class Plug extends Accessory

  # Add the 'property' definition here as we can't inherit from it
  @property: (name, accessors) ->
    Object.defineProperty @::, name, accessors

  constructor: (device) ->
    super device
    plug = device.plugList[0]
    @isOn         =  plug.onOff
    @switchable   =  plug.isSwitchable

  operate: (obj) ->
    if @switchable
      tradfri = @device.client
      await tradfri.operatePlug @device, obj

  switch: (onOff) ->
    @operate onOff: onOff
    .then (ok) =>
      ok

module.exports = Plug
