Coap = require('node-coap-client').CoapClient
{ URL } = require 'url'

Property = require './Property'
Device   = require './Device'
Group    = require './Group'

DEVICE = '15001'
GROUP  = '15004'

class CoAP

  constructor: (@hub, securityId) ->
    Coap.setSecurityParams @hub,
      psk:
        Client_identity: securityId
    @url = new URL "coaps://#{@hub}:5684"
    Coap.tryToConnect @url
    .then (connected) =>
      console.log "Connected", connected
    .catch (err) =>
      throw err

  @property 'deviceURL',
    get: ->
      url = new URL @url.href
      url.pathname = DEVICE
      url

  @property 'groupURL',
    get: ->
      url = new URL @url.href
      url.pathname = GROUP
      url

  GET: (url) ->          # Returns a promise
    Coap.request url, 'get'
    .then (result) ->
      throw new Error "#{url} returned #{result.code}" unless result.code.major is 2
      JSON.parse result.payload.toString()

  PUT: (url, payload) ->
    buffer = Buffer.from JSON.stringify payload
    Coap.request url, 'put', buffer
    .then (result) ->
      throw new Error "Result: #{result.code}" unless result.code.major is 2
      result


  reset: ->
    Coap.reset @hub

  devices: ->
    @GET @deviceURL

  device: (id) ->
    @deviceRaw id
    .then (raw) =>
      new Device raw, @

  deviceRaw: (id, disposable) ->
    return Promise.resolve() if disposable and @queue > 1
    url = @deviceURL
    url.pathname += '/' + id
    @GET url

  observed = new Set
  deviceObserve: (id, callback) ->
    url = @deviceURL
    url.pathname += '/' + id
    observed.add url
    Coap.observe url, 'get', callback

  unObserve: (id) ->
    url = @deviceURL
    url.pathname += '/' + id
    Coap.stopObserving url

  updateDevice: (id, payload) ->
    url = @deviceURL
    url.pathname += '/' + id
    @PUT url, payload

  groups: ->
    @GET @groupURL

  group: (id) ->
    @groupRaw id
    .then (raw) =>
      new Group raw, @

  groupRaw: (id, disposable) ->
    return Promise.resolve() if disposable and @queue > 1
    url = @groupURL
    url.pathname += '/' + id
    @GET url

  updateGroup: (id, payload) ->
    url = @groupURL
    url.pathname += '/' + id
    @PUT url, payload

module.exports = CoAP

process.on 'exit', =>
  console.log 'Cleaning up...'
  # Coap.stopObserving url for url from observed
  Coap.reset()
process.on 'SIGINT', ->
  process.exit()
process.on 'SIGTERM', ->
  process.exit()
process.on 'uncaughtException', (err) =>
  console.log 'Cleaning up for exception'
  Coap.reset()
  throw err
