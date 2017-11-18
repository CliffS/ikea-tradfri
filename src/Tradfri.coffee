NodeTradfri = require 'node-tradfri-client'

Client = NodeTradfri.TradfriClient
Types  = NodeTradfri.AccessoryTypes

Accessory = require './Accessory'
Group = require './Group'
Property = require './Property'

sleep = (time = 1) ->
  new Promise (resolve, reject) ->
    setTimeout ->
      resolve()
    , time * 1000

class Tradfri extends Property

  constructor: (@hub, @securityId) ->
    super()
    @client = new Client @hub

  @property 'stamp',
    get: ->
      new Date().toJSON()

  connect: ->
    new Promise (resolve, reject) =>
      @client.authenticate  @securityId
      .then (result) =>
        @client.connect result.identity, result.psk
      .then (ans) =>
        return reject new Error "Failed to connect" unless ans
        @client.on 'error', (err) =>
          console.log "ERROR:", err
        .on "device updated", (device) =>
          newdev = Accessory.update device
          # console.log @stamp, "device updated: #{newdev.name} - #{newdev.alive}"
        .on "device removed", (device) =>
          Accessory.delete device
          console.log @stamp, "device removed: #{device.name}"
        .on "group updated", (group) =>
          @groups.set group.instanceId, new Group group
          console.log @stamp, "group updated: #{group.name}"
        .on "group removed", (group) =>
          @groups.delete group.instanceId
          console.log @stamp, "group removed: #{group.name}"
        .on "scene updated", (scene) =>
          @scenes.add scene
          console.log @stamp, "scene updated: #{scene}"
        .on "scene removed", (scene) =>
          @scene.delete scene
          # console.log @stamp, "scene removed: #{scene}"
        Promise.all [
          @client.observeDevices()
          @client.observeGroupsAndScenes()
        ]
      .then (result) =>
        # await sleep 3
        console.log @stamp, "Resolving"
        resolve()
      .catch (err) ->
        reject err

  reset: ->
    @client.reset()

  destroy: ->
    @client.destroy()

  device: (name) ->
    Accessory.get name

  groups:  new Map
  scenes:  new Set

module.exports = Tradfri
