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

  # This should be called with either a securityId string
  # or an object containing the keys: identity & psk
  constructor: (@hub, @securityId) ->
    super()
    @client = new Client @hub

  connect: ->
    credentials = undefined
    (
      if typeof @securityId is 'string'
        @client.authenticate  @securityId
      else
        Promise.resolve
          identity: @securityId.identity
          psk:      @securityId.psk
    )
    .then (result) =>
      credentials = result
      @client.connect result.identity, result.psk
    .then (ans) =>
      throw new Error "Failed to connect" unless ans
      @client.on 'error', (err) =>
        console.error err # Just log it to STDERR and carry on
      .on "device updated", (device) =>
        newdev = Accessory.update device
      .on "device removed", (device) =>
        Accessory.delete device
      .on "group updated", (group) =>
        Group.update group
      .on "group removed", (group) =>
        Group.delete group
      .on "scene updated", (groupID, scene) =>
        group = Group.byID groupID
        throw new Error "Missing group #{groupID}" unless group
        group.addScene scene
      .on "scene removed", (groupID, scene) =>
        group = Group.byID groupID
        throw new Error "Missing group #{groupID}" unless group
        group.delScene scene
      @client.observeDevices()
    .then =>      # Need the devices in place so not Promise.all()
      @client.observeGroupsAndScenes()
    .then =>
      sleep 2     # Remove this when AlCalzone has fixed observeGroupsAndScenes
    .then =>
      credentials

  reset: ->
    @client.reset()

  destroy: ->
    @client.destroy()

  device: (name) ->
    Accessory.get name

  group: (name) ->
    Group.get name

module.exports = Tradfri
