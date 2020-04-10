NodeTradfri = require 'node-tradfri-client'

Client              = NodeTradfri.TradfriClient
Types               = NodeTradfri.AccessoryTypes
TradfriError        = NodeTradfri.TradfriError
TradfriErrorCodes   = NodeTradfri.TradfriErrorCodes

Accessory = require './Accessory'
Group     = require './Group'
Property  = require './Property'

States = Object.freeze
  DISCONNECTED: Symbol 'disconnected'
  CONNECTING:   Symbol 'connecting'
  CONNECTED:    Symbol 'connected'

sleep = (secs = 1) =>
  new Promise (resolve) =>
    setTimeout resolve, secs * 1000

Debug = require('debug') 'ikea-tradfri'

class Tradfri extends Property

  connectState: States.DISCONNECTED
  credentials = undefined

  # This should be called with either a securityId string
  # or an object containing the keys: identity & psk
  constructor: (@hub, @securityId, customLogger, passThrough) ->
    super()
    @debug = customLogger ? (msg, level) ->
      Debug msg
    params =
      watchConnection: true
    params.customLogger = customLogger if customLogger? and passThrough is true
    @client = new Client @hub, params

  connect: ->
    @debug "connectState: #{@connectState.toString()}", "debug"
    switch @connectState
      when States.CONNECTED
        Promise.resolve @credentials
      when States.CONNECTING
        new Promise (resolve,reject) =>
          await sleep .25 until @connectState is States.CONNECTED
          resolve @credentials
      when States.DISCONNECTED
        @connectState = States.CONNECTING
        (
          if typeof @securityId is 'string'
            @client.authenticate  @securityId
          else
            Promise.resolve
              identity: @securityId.identity
              psk:      @securityId.psk
        )
        .then (result) =>
          @credentials = result
          @client.removeAllListeners()
          @client.connect result.identity, result.psk
        .then (ans) =>
          unless ans
            throw new TradfriError "Failed to connect (response was empty)", TradfriErrorCodes.ConnectionFailed
          @client.on 'error', (err) =>
            if err instanceof TradfriError
              switch err.code
                when TradfriErrorCodes.NetworkReset, TradfriErrorCodes.ConnectionTimedOut
                  @debug err.message, "warn"
                when TradfriErrorCodes.AuthenticationFailed, TradfriErrorCodes.ConnectionFailed
                  @debug err.message, "error"
                  throw err
            else
              @debug err.message, "error"
              throw err
          .on "device updated", (device) =>
            newdev = Accessory.update device
            @debug "device updated: #{device.name} (type=#{device.type} [#{newdev.type}])", "debug"
          .on "device removed", (id) =>
            Accessory.delete id
            @debug "device removed: #{id}", "debug"
          .on "group updated", (group) =>
            Group.update group
            @debug "group updated: #{group.name}", "debug"
          .on "group removed", (groupID) =>
            group = Group.delete groupID
            @debug "group removed: #{group?.name}", "debug"
          .on "scene updated", (groupID, scene) =>
            group = Group.byID groupID
            if group?
              group.addScene scene
              @debug "scene updated: #{group.name}: #{scene.name}", "debug"
            else
              @debug "scene updated: Missing group #{groupID}", "warn"
          .on "scene removed", (groupID, sceneID) =>
            group = Group.byID groupID
            if group?
              group.delScene sceneID
              @debug "scene removed from group.name: #{sceneID}", "debug"
            else
              @debug "scene removed: Missing group #{groupID}", "warn"
          @client.observeDevices()
        .then =>      # Need the devices in place so not Promise.all()
          @debug "observeDevices resolved", "debug"
          @client.observeGroupsAndScenes()
        .then =>
          @debug "observeGroupsAndScenes resolved: connect complete", "debug"
          @connectState = States.CONNECTED
          @credentials
        .catch (err) =>
          if err instanceof TradfriError
            switch err.code
              when TradfriErrorCodes.NetworkReset, TradfriErrorCodes.ConnectionTimedOut
                return @debug err.message, "warn"
              when TradfriErrorCodes.AuthenticationFailed, TradfriErrorCodes.ConnectionFailed
                @debug err.message, "error"
          throw err


  reset: ->
    @client.reset()
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
