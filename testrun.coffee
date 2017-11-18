#!/usr/local/bin/coffee

Tradfri = require './src/Tradfri'
Group = require './src/Group'
Identity = require './identity'

sleep = (time = 10) ->
  new Promise (resolve, reject) ->
    setTimeout resolve, time * 1000

tradfri = new Tradfri 'tradfri.tallinn.may.be', Identity.id

tradfri.connect()
.then ->
  # await sleep()
  console.log '------------------------------------'
  #console.log tradfri.device 'Hallway 2'
  #console.log tradfri.device 'Hallway Remote'
  #console.log '------------------------------------'
  #devices = tradfri.device [ 'Hallway 2', 'Hallway Remote' ]
  #console.log devices
  # console.log Array.from tradfri.devices.keys()
  # keys = Array.from tradfri.devices.keys()
  # console.log keys
  await sleep 3
  group = Group.get 'TRADFRI group 4'
  console.log group
  await sleep 2
  group.scene = 224204
  await sleep 2
  group.level = 100
  await sleep 2
  console.log group
  await sleep 86400
  tradfri.reset()
.catch (err) ->
  console.log err

