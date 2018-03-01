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
  groups = [
    tradfri.group 'Living Room'
    # tradfri.group 'Hallway'
  ]
  console.log groups
  console.log ( group.scenes for group in groups )
  # group.switch = on for group in groups
  group.scene = 'FOCUS' for group in groups
  console.log ( group.scene for group in groups )
.catch (err) ->
  console.log err
.finally ->
  await sleep 10
  console.log 'Closing...'
  tradfri.close()
  process.exit()
  # WTF.dump()
