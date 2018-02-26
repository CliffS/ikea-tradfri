Property = require './Property'
Scene = require './Scene'

class Group extends Property

  @groups = new Map

  @update: (group) ->
    newgroup = new Group group
    if Group.groups.has newgroup.id
      grp = Group.groups.get newgroup.id
      grp.change newgroup # , group
      grp
    else
      Group.groups.set newgroup.id, newgroup
      newgroup

  @delete: (group) ->
    deleted = Group.groups.get group.instanceId
    if deleted?
      Group.groups.delete group.instanceId
      deleted.delete()

  @get: (name) ->
    return group for group from Group.groups.values() when group.name is name

  @byID: (id) ->
    Group.groups.get id

  constructor: (group) ->
    super()
    @deleted = false
    @id       =  group.instanceId
    @name     =  group.name
    @isOn     =  group.onOff
    @dimmer   =  group.dimmer
    @sceneId  =  group.sceneId

    Object.defineProperty @, 'rawGroup',
      value: group

    Object.defineProperty @, 'groupScenes',
      value: new Map

  change: (newgroup) ->
    @[k] = v for own k, v of newgroup when v?

  addScene: (scene) ->
    scene = new Scene scene unless scene instanceof Scene
    @groupScenes.set scene.id, scene

  getScene: (name) ->
    return scene for scene from @groupScenes.values() when scene.name is name

  delScene: (sceneID) ->
    @groupScenes.delete sceneID

  @property 'switch',
    set: (onOff) ->
      @rawGroup.toggle onOff
      @isOn = onOff
    get: ->
      @isOn

  @property 'scene',
    set: (name) ->
      id = @getScene(name)?.id
      if id
        @rawGroup.operateGroup sceneId: id
        .then (ok) ->
          @sceneId = id if ok
        .catch (err) =>
    get: ->
      @groupScenes.get(@sceneId)?.name

  @property 'scenes',
    get: ->
      Array.from(@groupScenes.values()).map (value) => value.name

  @property 'level',
    set: (level) ->
      @rawGroup.operateGroup dimmer: level
      .then (ok) =>
        @dimmer = level if ok
      .catch (err) =>
    get: ->
      @dimmer



module.exports = Group
