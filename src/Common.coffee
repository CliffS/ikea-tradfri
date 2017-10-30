EventEmitter = require 'events'
Property = require './Property'

class Common extends EventEmitter

  constructor: (@raw, @coap) ->
    super()

  @property 'id',
    get: -> @raw[9003]

  @property 'name',
    get: -> @raw[9001]

  @props = [
      'id'
      'name'
      'type'
      'manufacturer'
      'ison'
      'colour'
      'brightness'
      'devices'
    ]

  @property 'props',
    get: -> @constructor.props

  toObject: ->
    obj = {}
    for prop in @props
      obj[prop] = @[prop] if @[prop]?
    obj

  toString: ->
    JSON.stringify @toObject(), null, 2

module.exports = Common
