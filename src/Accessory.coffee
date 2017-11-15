EventEmitter = require 'events'
Types   =  require('node-tradfri-client').AccessoryTypes

console.log Types

class Accessory # extends EventEmitter

  # Bulb, Remote, Sensor etc. should not be constructed externally
  # but should be created here
  @create: (device) ->
    type = Types[device.type]
    switch type
      when 'lightbulb'
        item = new Bulb device
        Accessory.lights.set item
      when 'remote'
        item = new Remote device
        Accessory.remotes.set item
      when 'motionSensor'
        item = new Sensor device
        Accessory.sensors.set item
      else
        throw new Error "Unknown type: #{device.type}"
    item

  @lights:  new Map
  @remotes: new Map
  @sensors: new Map

  # This is the inherited constructor
  constructor: (device) ->
    # super()
    @id = device.instanceId
    @type = Types[device.type]
    @name = device.name
    @lastSeen = new Date device.lastseen

    Object.defineProperty @, 'device',  # immutable property
      value: device

module.exports = Accessory

Bulb    =  require  './Bulb'
Remote  =  require  './Remote'
Sensor  =  require  './Sensor'

