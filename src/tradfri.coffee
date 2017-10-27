DNS = require 'dns'
util = require 'util'
CoAP = require './CoAP'
sizeof = require('sizeof').sizeof

class Tradfri

  constructor: (hub, securityId) ->
    @ip = hub if hub.match /^\d{1,3}.(?:.\d{1,3}){3}$/
    @coap = new CoAP hub, securityId

  reset: ->
    @coap.reset()

  getDeviceIds: ->
    @coap.devices()

  getDevices: ->
    @getDeviceIds()
    .then (ids) =>
      Promise.all (@getDevice id for id in ids)

  getDevice: (id) ->
    @coap.device id

  getGroupIds: ->
    @coap.groups()

  getGroups: ->
    @getGroupIds()
    .then (ids) =>
      Promise.all (@getGroup id for id in ids)

  getGroup: (id) ->
    @coap.group id


ID = require('../identity.json').id
test = new Tradfri 'tradfri.tallinn.may.be', ID
###
test.getDeviceIds()
.then (ids) ->
  console.log ids
  test.getDevices()
.then (devices) ->
  console.log (device.toObject() for device in devices)
test.getGroupIds()
.then (ids) ->
  console.log ids
  test.getGroup ids[0]
.then (group) ->
  console.log group
  console.log group.toObject()
###
test.getGroups()
.then (groups) ->
  console.log (group.toObject() for group in groups)
  for group in groups
    do (group) =>
      group.on 'changed', (what) ->
        console.log 'GROUP CHANGED', @name, what
  groups[1].getDevices()
.then (devices) ->
  dowhat = (what) ->
    console.log 'CHANGED:', @name, what
  for device in devices
    do (device) ->
      device.on 'changed', dowhat
  # console.log (device.toObject() for device in devices)
.catch (err) ->
  console.log err
  test.reset()
