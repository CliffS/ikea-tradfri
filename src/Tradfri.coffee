NodeTradfri = require 'node-tradfri-client'

Client = NodeTradfri.TradfriClient
Types  = NodeTradfri.AccessoryTypes

Accessory = require './Accessory'
Group = require './Group'
Property = require './Property'

DEBUG = false

States = Object.freeze
  DISCONNECTED: Symbol 'disconnected'
  CONNECTING:   Symbol 'connecting'
  CONNECTED:    Symbol 'connected'

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

  connectState: States.DISCONNECTED

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
      switch @connectState
        when States.DISCONNECTED
          @connectState = States.CONNECTING
          @client.connect result.identity, result.psk
          .then (ans) =>
            throw new Error "Failed to connect" unless ans
            @client.on 'error', (err) =>
              console.error err # Just log it to STDERR and carry on
            .on "device updated", (device) =>
              newdev = Accessory.update device
              console.log "device updated: #{device.name}" if DEBUG
            .on "device removed", (device) =>
              Accessory.delete device
            .on "group updated", (group) =>
              Group.update group
              console.log "group updated: #{group.name}" if DEBUG
            .on "group removed", (group) =>
              Group.delete group
            .on "scene updated", (groupID, scene) =>
              group = Group.byID groupID
              console.log "scene updated: #{group.name}: #{scene.name}" if DEBUG
              throw new Error "Missing group #{groupID}" unless group
              group.addScene scene
            .on "scene removed", (groupID, scene) =>
              group = Group.byID groupID
              throw new Error "Missing group #{groupID}" unless group
              group.delScene scene.instanceId
            @client.observeDevices()
          .then =>      # Need the devices in place so not Promise.all()
            console.log "observeDevices resolved" if DEBUG
            @client.observeGroupsAndScenes()
          .then =>
            console.log "observeGroupsAndScenes resolved" if DEBUG
            @connectState = States.CONNECTED
            credentials
        when States.CONNECTING
          await sleep .25 until @connectState is States.CONNECTED
          credentials
        when States.CONNECTED
          credentials

  reset: ->
    @client.reset()

  close: ->
    @client.destroy()
    Group.close()
    Accessory.close()
    delete @client

  device: (name) ->
    Accessory.get name

  group: (name) ->
    Group.get name

module.exports = Tradfri
