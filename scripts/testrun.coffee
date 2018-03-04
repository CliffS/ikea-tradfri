#!/usr/local/bin/coffee
#

# WTF = require 'wtfnode'

require('promise.prototype.finally').shim()

Tradfri = require '../src/Tradfri'
Identity = require '../identity'

sleep = (time = 10) ->
  new Promise (resolve, reject) ->
    setTimeout resolve, time * 1000

tradfri = new Tradfri 'tradfri.tallinn.may.be', Identity #.id

tradfri.connect()
.then (credentials) ->
  console.log "Credentials: ", credentials
  console.log '------------------------------------'

###
  groups = [
    tradfri.group 'Living Room'
    tradfri.group 'Hallway'
  ]
  console.log groups
  console.log ( group.scenes for group in groups )
  console.log ( group.scene for group in groups )
  await group.setScene 'FOCUS' for group in groups
  console.log ( group.scene for group in groups )
  console.log 'Sleeping...', new Date().toTimeString()
  await sleep 30
  await group.switch off for group in groups
  console.log 'Slept', new Date().toTimeString()
  console.log groups
.catch (err) ->
  console.log err
.finally ->
  console.log 'Closing...'
  tradfri.close()
  process.exit()
  # WTF.dump()
###

  bulb = tradfri.device 'Sylvia Standard Lamp'
  console.log bulb
