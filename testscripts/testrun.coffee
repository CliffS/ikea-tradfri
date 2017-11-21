#!/usr/local/bin/coffee

Tradfri = require '../src/Tradfri'
Identity = require '../identity'

sleep = (time = 10) ->
  new Promise (resolve, reject) ->
    setTimeout resolve, time * 1000

tradfri = new Tradfri 'tradfri.tallinn.may.be', Identity #.id

tradfri.connect()
.then (credentials) ->
  console.log "Credentials: ", credentials
  # tradfri_1511083761610
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
  # await sleep 3
  group = tradfri.group 'TRADFRI group 4'
  console.log group
  await sleep 1
  group.scene = 'test'
  await sleep 1
  group.level = 100
  await sleep 1
  console.log group
  console.log "Scene: #{group.scene}"
  console.log ( [scene.id, scene.name] for scene in group.scenes )
  console.log '------------------------'
  bulb = tradfri.device 'Cliff Standard Lamp'
  .on 'changed', (change) ->
    console.log change #, bulb
  console.log bulb
  bulb.color = 'glow'
  for colour in [100..0] by -10
    console.log "Setting brightness to #{colour}"
    bulb.level = colour
    await sleep 1
  for colour in [0..100] by 10
    console.log "Setting brightness to #{colour}"
    bulb.level = colour
    await sleep 1
  bulb.color = 'white'
  await sleep 1
  bulb.switch = off
  await sleep 86400
  tradfri.reset()
.catch (err) ->
  console.log "TESTRUN ERROR: #{err}"
  process.exit 1

