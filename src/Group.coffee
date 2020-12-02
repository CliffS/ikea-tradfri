Property = require './Property'
Scene = require './Scene'
Accessory = require './Accessory'
{Sleep} = require './Utils'

TRANSITION = 3

class Group extends Property

  @groups = new Map

  @update: (group) ->
    newgroup = new Group group
    if Group.groups.has newgroup.id
      # it's an update
      grp = Group.groups.get newgroup.id
      grp.change newgroup # , group
      grp
    else
      # it's a create
      Group.groups.set newgroup.id, newgroup
      Group.superGroup = newgroup if newgroup.name is 'SuperGroup'
      newgroup

  @delete: (instanceId) ->
    deleted = Group.groups.get instanceId
    if deleted?
      Group.groups.delete group.instanceId
    deleted

  @get: (name) ->
    return group for group from Group.groups.values() when group.name is name

  @byID: (id) ->
    Group.groups.get id

  @close: ->
    @groups.clear()

  @listGroups: ->
    group for group from Group.groups.values() when not group.isSuper

  constructor: (group) ->
    super()
    @deleted  = false
    @id       =  group.instanceId
    @name     =  group.name
    @isOn     =  group.onOff
    @dimmer   =  group.dimmer
    @sceneId  =  group.sceneId
    firstdevice = Accessory.byID group.deviceIDs[0]
    firstdevice?.on 'changed', (now) =>
      @isOn = now.isOn if now.isOn?


    Object.defineProperty @, 'rawGroup',
      value: group

    Object.defineProperty @, 'groupScenes',
      value: new Map

  change: (newgroup) ->
    @[k] = v for own k, v of newgroup when v?

  addScene: (scene) ->
    throw new Error "Scenes are now only global" unless @isSuper
    scene = new Scene scene unless scene instanceof Scene
    @groupScenes.set scene.id, scene

  getScene: (name) ->
    throw new Error "Scenes are now only global" unless @isSuper
    return scene for scene from @groupScenes.values() when scene.name is name

  delScene: (sceneID) ->
    throw new Error "Scenes are now only global" unless @isSuper
    @groupScenes.delete sceneID

  operate: (operation) ->
    operation.transitionTime = TRANSITION
    operation.force = true
    @rawGroup.client.operateGroup @rawGroup, operation

  switch: (onOff) ->
    @rawGroup.toggle onOff
    .then (ok) =>
      @isOn = onOff

  setBrightness: (level) ->
    @operate
      dimmer: level
      onOff: true
    .then (ok) =>
      @dimmer = level
      ok

  setColour: (colour, spectrum = 'white') ->
    bulbs = (Accessory.byID id for id in @rawGroup.deviceIDs).filter (item) =>
      item.type is 'Bulb' and item.spectrum is spectrum
    await bulb.setColour colour for bulb in bulbs

  setScene: (name) ->
    throw new Error "Scenes are now only global" unless @isSuper
    id = @getScene(name)?.id
    if id
      @rawGroup.activateScene id
      .then (ok) =>
        @sceneId = id
    else
      Promise.reject new Error "Can't find scene #{name}"

  @property 'isSuper',
    get: ->
      @name is 'SuperGroup'

  @property 'scene',
    get: ->
      throw new Error "Scenes are now only global" unless @isSuper
      @groupScenes.get(@sceneId)?.name
    set: (name) ->
      throw new Error "Scenes are now only global" unless @isSuper
      try await @setScene name

  @property 'scenes',
    get: ->
      throw new Error "Scenes are now only global" unless @isSuper
      Array.from(@groupScenes.values()).map (value) => value.name

  setLevel: (level) ->
    @rawGroup.setBrightness level
    .then (ok) =>
      @dimmer = level

  @property 'level',
    get: ->
      @dimmer



module.exports = Group
