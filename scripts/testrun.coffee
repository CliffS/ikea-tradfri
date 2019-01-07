#!/usr/local/bin/coffee
#

# WTF = require 'wtfnode'

require('promise.prototype.finally').shim()

Tradfri = require '../src/Tradfri'
Identity = require '../identity'

sleep = (time = 10) ->
  new Promise (resolve, reject) ->
    setTimeout resolve, time * 1000

tradfri = new Tradfri 'tradfri.tallinn.may.be', Identity, true

tradfri.connect()
.then (credentials) ->
  console.log "Credentials: ", credentials
  console.log '------------------------------------'
  bulb = tradfri.device 'Sylvia Standard Lamp'
  bulb.on 'changed', (change) =>
    console.log change
  await bulb.switch off
  groups = [
    tradfri.group 'Living Room'
    tradfri.group 'Hallway'
  ]
  console.log groups
  await tradfri.reset()
  console.log "reset called"
  console.log "switching on #{bulb.name}"
  await bulb.switch on
  await sleep 10
  await tradfri.reset()
  console.log "reset called"
  console.log "switching off #{bulb.name}"
  await bulb.switch off
  await sleep 10 * 60
  ###
  console.log ( group.scenes for group in groups )
  console.log ( group.scene for group in groups )
  await group.setScene 'FOCUS' for group in groups
  console.log ( group.scene for group in groups )
  console.log 'Sleeping...', new Date().toTimeString()
  await sleep 30
  await group.switch off for group in groups
  console.log 'Slept', new Date().toTimeString()
  console.log groups
  ###
.catch (err) ->
  console.log err
.finally ->
  console.log 'Closing...'
  tradfri.close()
  # process.exit()
  WTF?.dump()

  ###
  console.log bulb
  ###
