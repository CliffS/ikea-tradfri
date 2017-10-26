Property = require './Property'

class Common extends Property

  constructor: (@raw, @coap) ->
    super()

  @property 'id',
    get: -> @raw[9003]

  @property 'name',
    get: -> @raw[9001]

  toObject: ->
    obj =
      id:           @id
      name:         @name
    obj.type        = @type if @type
    obj.manufacturer= @manufacturer if @manufacturer
    obj.on          = @on if @on?
    obj.colour      = @colour if @colour?
    obj.brightness  = @brightness if @brightness?
    obj.devices     = @devices if @devices?
    obj

  valueOf: ->
    @id

  toString: ->
    JSON.stringify @toObject(), null, 2

module.exports = Common
