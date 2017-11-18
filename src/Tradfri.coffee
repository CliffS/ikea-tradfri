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
          Group.update group
          console.log @stamp, "group updated: #{group.name}"
          # console.log group
        .on "group removed", (group) =>
          Group.delete group
          console.log @stamp, "group removed: #{group.name}"
        .on "scene updated", (groupID, scene) =>
          group = Group.byID groupID
          throw new Error "Missing group #{groupID}" unless group
          group.addScene scene
          console.log @stamp, "group #{group.name}, scene updated: ", scene.instanceId, scene.name
          # console.log scene if scene.name is 'Crochet'
        .on "scene removed", (groupID, scene) =>
          group = Group.byID groupID
          throw new Error "Missing group #{groupID}" unless group
          group.delScene scene
          console.log @stamp, "group #{group.name}, scene removed: #{scene.id}"
        @client.observeDevices()
      .then =>      # Need the devices in place so not Promise.all()
        @client.observeGroupsAndScenes()
      .then =>
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
