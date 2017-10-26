class Property

  @property: (name, accessors) ->
    Object.defineProperty @::, name, accessors


module.exports = Property
