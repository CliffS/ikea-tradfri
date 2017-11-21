Client = require('node-tradfri-client').TradfriClient
Identity = require './identity'

sleep = (time = 10) ->
  new Promise (resolve, reject) ->
    setTimeout resolve, time * 1000

tradfri = new Client Identity.host

do ->
  starting = true
  success = await tradfri.connect Identity.identity, Identity.psk
  console.log "Success: #{success}"
  devices = changed = []
  tradfri.on 'device updated', (device) ->
    if starting then devices.push device.name else changed.push device.name
  tradfri.observeDevices (response) ->
  .then (response) ->
    starting = false
    count = 0
    console.log "#{count++} #{dev}" for dev in devices.sort()
    console.log '--------------------------------------'
    process.env.DEBUG = 'node-*-client'
    await sleep 5
    console.log changed.sort()
  .catch (err) ->
    console.error "ERROR: #{err}"


