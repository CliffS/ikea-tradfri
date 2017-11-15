NodeTradfri = require 'node-tradfri-client'

Client = NodeTradfri.TradfriClient
Types  = NodeTradfri.AccessoryTypes

Accessory = require './Accessory'
Group = require './Group'

class Tradfri

  constructor: (@hub, @securityId) ->
    @client = new Client @hub

  connect: ->
    new Promise (resolve, reject) =>
      @client.authenticate  @securityId
      .then (result) =>
        console.log result
        @client.connect result.identity, result.psk
      .then (ans) =>
        return reject new Error "Failed to connect" unless ans
        @client.on 'error', (err) =>
          console.log "ERROR:", err
        .on "device updated", (device) =>
          newdev = Accessory.update device
          console.log "device updated:", newdev
          @devices.set newdev.id, newdev
        .on "device removed", (device) =>
          Accessory.delete device
          console.log "device removed: #{device.name}"
        .on "group updated", (group) =>
          @groups.set group.instanceId, new Group group
          console.log "group updated: #{group.name}"
        .on "group removed", (group) =>
          @groups.delete group.instanceId
          console.log "group removed: #{group.name}"
        .on "scene updated", (scene) =>
          @scenes.add scene
          console.log "scene updated: #{scene}"
        .on "scene removed", (scene) =>
          @scene.delete scene
          console.log "scene removed: #{scene}"
        Promise.all [
          @client.observeDevices()
          @client.observeGroupsAndScenes()
        ]
      .then ->
        resolve()
      .catch (err) ->
        reject err


  reset: ->
    @client.reset()

  destroy: ->
    @client.destroy()

  devices: new Map
  groups:  new Map
  scenes:  new Set

module.exports = Tradfri
