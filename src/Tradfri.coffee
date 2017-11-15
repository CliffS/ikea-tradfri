NodeTradfri = require 'node-tradfri-client'

Client = NodeTradfri.TradfriClient
Types  = NodeTradfri.AccessoryTypes


class Tradfri

  constructor: (@hub, @securityId) ->
    @client = new Client @hub

  connect: ->
    new Promise (resolve, reject) =>
      @client.authenticate  @securityID
      .then (identity, psk) =>
        @client.connect identity, psk
      .then (ans) =>
        return reject new Error "Failed to connect" unless ans
        @client.on 'error', (err) =>
          console.log "ERROR:", err
        .on "device updated", (device) =>
          @devices.set device.instanceId, new Device device
          console.log "device updated: #{device.name.padEnd 23} #{atype device}"
        .on "device removed", (device) =>
          @devices.delete device.instanceId
          console.log "device removed: #{device.name.padEnd 23} #{atype device}"
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

  reset: ->
    @client.reset()

  destroy: ->
    @client.destroy()

  devices: new Map
  groups:  new Map
  scenes:  new Set

  getDeviceIds: ->
    @coap.devices()

  getDevices: ->
    @getDeviceIds()
    .then (ids) =>
      Promise.all (@getDevice id for id in ids)

  getDevice: (id) ->
    @coap.device id

  getGroupIds: ->
    @coap.groups()

  getGroups: ->
    @getGroupIds()
    .then (ids) =>
      Promise.all (@getGroup id for id in ids)

  getGroup: (id) ->
    @coap.group id


