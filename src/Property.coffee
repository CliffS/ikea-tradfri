EventEmitter = require 'events'

class Property extends EventEmitter

  @property: (name, accessors) ->
    Object.defineProperty @::, name, accessors


module.exports = Property
