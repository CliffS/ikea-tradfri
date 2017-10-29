Coap = require('node-coap-client').CoapClient
{ URL } = require 'url'
Throttler = require 'p-throttler'

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
    @throttler = Throttler.create 10,
      coap: 1
    setInterval =>
      console.log "queue: #{@queue}"
    , 5000

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

  @property 'queue',
    get: ->
      @throttler._queue.coap.length

  GET: (url) ->          # Returns a promise
    @throttler.enqueue =>
      Coap.request url, 'get',
        keepAlive: true
        confirmable: false
        observe: false
        retransmit: false
    , 'coap'
    .then (result) ->
      JSON.parse result.payload.toString()

  PUT: (url, payload) ->
    buffer = Buffer.from JSON.stringify payload
    @throttler.enqueue =>
      Coap.request url, 'put', buffer,
        keepAlive: true
        confirmable: true
        observe: false
    , 'coap'
    .then (result) ->
      throw new Error "Result: #{result.code}" unless result.code.major is 2
      result

  reset: ->
    @throttler.abort()
    .then =>
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
