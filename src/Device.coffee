Common = require './Common'
EventEmitter = require 'events'
IsEqual = require 'deep-equal'

INTERVAL = 1000 / 5     # 5 times a second

class Device extends Common

  constructor: ->
    super arguments...
    if @coap
      @on 'newListener', (event) =>
        if event is 'changed' and @listenerCount('changed') is 0
          @coap.deviceObserve @id, (response) =>
            raw = JSON.parse response.payload.toString()
            return if IsEqual raw, @raw
            dev = new Device raw
            changed = id: @id
            for prop in @props[1..]
              changed[prop] = [@[prop], dev[prop]] if @[prop] isnt dev[prop]
            if Object.keys(changed).length is 1
              changed.old = @raw
              changed.new = raw
            @raw = raw
            @emit 'changed', changed
          .then ->
          .catch (err) ->
            throw err
      @on 'removeListener', (event) =>
        @coap.unObserve @id if @listenerCount('changed') is 0

  @property 'type',
    get: -> @raw[3][1]

  @property 'manufacturer',
    get: -> @raw[3][0]

  @property 'ison',
    get: ->
      ison = @raw[3311]?[0][5850]
      ison is 1 if ison?

  switch: (onoff) ->
    value = if onoff then 1 else 0
    job =
      '3311': [
        '5850' : value
      ]
    @coap.updateDevice @id, job
    .then =>
      @raw[3311]?[0][5850] = value
      @

  @property 'colour',
    get: -> @raw[3311]?[0][5706]

  @property 'color',
    get: -> @colour

  @property 'brightness',
    get: ->
      bright = @raw[3311]?[0][5851]
      Math.round bright * 100 / 254 if bright?

module.exports = Device
