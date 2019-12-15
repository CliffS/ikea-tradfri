NodeTradfri = require 'node-tradfri-client'
require('promise.prototype.finally').shim()

Client = NodeTradfri.TradfriClient
Types  = NodeTradfri.AccessoryTypes

Accessory = require './Accessory'
Group = require './Group'
Property = require './Property'

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
  constructor: (@hub, @securityId, @debug = false) ->
    super()
    @client = new Client @hub,
      watchConnection: true

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
          @client.removeAllListeners()
          @client.connect result.identity, result.psk
          .then (ans) =>
            throw new Error "Failed to connect" unless ans
            @client.on 'error', (err) =>
              console.error err # Just log it to STDERR and carry on
            .on "device updated", (device) =>
              newdev = Accessory.update device
              console.log "device updated: #{device.name} (type=#{device.type} [#{newdev.type}])" if @debug
            .on "device removed", (device) =>
              Accessory.delete device
            .on "group updated", (group) =>
              Group.update group
              console.log "group updated: #{group.name}" if @debug
            .on "group removed", (group) =>
              Group.delete group
            .on "scene updated", (groupID, scene) =>
              group = Group.byID groupID
              console.log "scene updated: #{group.name}: #{scene.name}" if @debug
              throw new Error "Missing group #{groupID}" unless group
              group.addScene scene
            .on "scene removed", (groupID, scene) =>
              group = Group.byID groupID
              throw new Error "Missing group #{groupID}" unless group
              group.delScene scene.instanceId
            @client.observeDevices()
          .then =>      # Need the devices in place so not Promise.all()
            console.log "observeDevices resolved" if @debug
            @client.observeGroupsAndScenes()
          .then =>
            console.log "observeGroupsAndScenes resolved" if @debug
            @connectState = States.CONNECTED
            credentials
        when States.CONNECTING
          await sleep .25 until @connectState is States.CONNECTED
    .finally =>
      credentials


  reset: ->
    Promise.resolve()
    .then =>
      @client.reset()
      @connectState = States.DISCONNECTED
    .then =>
      @connect()

  close: ->
    @client.destroy()
    Group.close()
    Accessory.close()
    delete @client

  @property 'devices',
    get: ->
      Accessory.listDevices()

  @property 'groups',
    get: ->
      Group.listGroups()

  device: (name) ->
    Accessory.get name

  group: (name) ->
    Group.get name

module.exports = Tradfri
