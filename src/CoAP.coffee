Coap = require('node-coap-client').CoapClient
{ URL } = require 'url'

Property = require './Property'
Device   = require './Device'
Group    = require './Group'

DEVICE = '15001'
GROUP  = '15004'

class CoAP extends Property

  constructor: (@hub, securityId) ->
    super()
    Coap.setSecurityParams @hub,
      psk:
        Client_identity: securityId
    @url = new URL "coaps://#{@hub}:5684"

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
      # keepAlive: false
      # confirmable: false
      # observe: false
    .then (result) ->
      JSON.parse result.payload.toString()

  PUT: (url, payload) ->
    buffer = Buffer.from JSON.stringify payload
    Coap.request url, 'put', buffer
      # keepAlive: false
      # confirmable: false
      # observe: false
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

  deviceRaw: (id) ->
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

  groupRaw: (id) ->
    url = @groupURL
    url.pathname += '/' + id
    @GET url

  updateGroup: (id, payload) ->
    url = @groupURL
    url.pathname += '/' + id
    @PUT url, payload

module.exports = CoAP
