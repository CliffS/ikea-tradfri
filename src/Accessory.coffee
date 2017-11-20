EventEmitter = require 'events'
Types   =  require('node-tradfri-client').AccessoryTypes

console.log Types

class Accessory extends EventEmitter

  @devices: new Map

  # Bulb, Remote, Sensor etc. should not be constructed externally
  # but should be created here
  @update: (device) ->
    type = Types[device.type]
    switch type
      when 'lightbulb'
        item = new Bulb device
      when 'remote'
        item = new Remote device
      when 'motionSensor'
        item = new Sensor device
      else
        throw new Error "Unknown type: #{device.type}"
    if Accessory.devices.has item.id
      dev = @devices.get item.id
      dev.change item
      @device = device
      dev
    else
      Accessory.devices.set item.id, item
      item

  @delete: (device) ->
    deleted = Accessory.devices.get device.instanceId
    if deleted?
      Accessory.devices.delete device.instanceId
      deleted.delete()

  @get: (name) ->
    vals = Accessory.devices.values()
    if Array.isArray name
      item for item from vals when item.name in name
    else
      return item for item from vals when item.name is name

  @byID: (id) ->
    Accessory.devices.get id

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
    result  = name: @name
    changed = {}
    for own k, v of newer when v isnt @[k] and k[0] isnt '_'
      changed[k] =
        old: @[k]
        new: newer[k]
      @[k] = newer[k]
    result.changed = changed
    # don't emit a change unless something's actually changed
    @emit 'changed', result if Object.keys(changed).length isnt 0

  delete: ->
    @deleted = true
    @emit 'deleted', @name


module.exports = Accessory

Bulb    =  require  './Bulb'
Remote  =  require  './Remote'
Sensor  =  require  './Sensor'

