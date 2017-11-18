Property = require './Property'

class Group extends Property

  @groups = new Map

  @update: (group) ->
    newgroup = new Group group
    if Group.groups.has newgroup.id
      grp = Group.groups.get newgroup.id
      grp.change newgroup
      grp
    else
      Group.groups.set newgroup.id, newgroup
      newgroup

  @delete: (group) ->
    deleted = Group.groups.get group.instanceId
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
      writable: true
      value: group

  change: (newgroup) ->
    @[k] = v for own k, v of newgroup when v?

  @property 'switch',
    set: (onOff) ->
      rawGroup.toggle onOff
      @isOn = onOff
    get: ->
      @isOn

  @property 'scene',
    set: (id) ->
      # console.log @rawGroup
      # process.exit()
      @rawGroup.operateGroup sceneId: id
      .then (ok) ->
        @sceneId = id if ok
      .catch (err) ->
        console.log err
    get: ->
      @sceneId

  @property 'level',
    set: (level) ->
      @rawGroup.operateGroup dimmer: level
      .then (ok) =>
        console.log 'OK', ok, @
        @dimmer = level if ok
    get: ->
      @dimmer



module.exports = Group
