EventEmitter = require 'events'
Types   =  require('node-tradfri-client').AccessoryTypes

class Accessory extends EventEmitter

  @devices: new Map

  # Bulb, Remote, Sensor etc. should not be constructed externally
  # but should be created here
  @update: (device) ->
    type = Types[device.type]
    item = switch type
      when 'lightbulb'
        new Bulb device
      when 'remote'
        new Remote device
      when 'motionSensor'
        new Sensor device
      when 'plug'
        new Plug device
      else
        # It's an unknown device: return a generic Accessory
        new Accessory device
    if @devices.has item.id
      dev = @devices.get item.id
      dev.change item
      dev.device = device
      dev
    else
      @devices.set item.id, item
      item

  @delete: (device) ->
    deleted = @devices.get device.instanceId
    if deleted?
      @devices.delete device.instanceId
      deleted.delete()

  @get: (name) ->
    vals = @devices.values()
    if Array.isArray name
      item for item from vals when item.name in name
    else
      return item for item from vals when item.name is name

  @byID: (id) ->
    @devices.get id

  @close: ->
    @devices.clear()

  @listDevices: ->
    ( device for device from @devices.values() )

  # This is the inherited constructor
  constructor: (device) ->
    super()
    @deleted = false
    @id = device.instanceId
    #@type = Types[device.type]
    @name = device.name
    @alive = device.alive

    Object.defineProperty @, 'device',  # non-enumerable property
      writable: true
      value: device

    Object.defineProperty @, 'type',
      enumerable: true
      value: @.constructor.name

  change: (newer) ->
    was = name: @name
    now = name: @name
    for own k, v of newer when v isnt @[k] and k[0] isnt '_'
      was[k] = @[k]
      now[k] = newer[k]
      @[k] = newer[k]
    # don't emit a change unless something's actually changed
    @emit 'changed', now, was unless Object.keys(now).length is 1

  delete: ->
    @deleted = true
    @emit 'deleted', @name


module.exports = Accessory

Bulb    =  require  './Bulb'
Remote  =  require  './Remote'
Sensor  =  require  './Sensor'
Plug  =  require  './Plug'

