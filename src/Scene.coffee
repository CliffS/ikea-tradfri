Property = require './Property'

class Scene extends Property

  constructor: (scene) ->
    super()
    @deleted     =  false
    @id          =  scene.instanceId
    @name        =  scene.name
    @predefined  =  scene.isPredefined
    @index       =  scene.sceneIndex
    @lights      =  (light.instanceId for light in scene.lightSettings ? [])

module.exports = Scene
