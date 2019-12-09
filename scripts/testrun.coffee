#!/usr/local/bin/coffee
#

# WTF = require 'wtfnode'

require('promise.prototype.finally').shim()

Tradfri = require '../src/Tradfri'
Identity = require '../identity'

sleep = (time = 10) ->
  new Promise (resolve, reject) ->
    setTimeout resolve, time * 1000

# Identity = "hOPupErDoLDw7gDe"
tradfri = new Tradfri 'tradfri.tallinn.may.be', Identity #, true

tradfri.connect()
.then (credentials) ->
  credentials.id = Identity.id ? Identity
  console.log "Credentials: ", JSON.stringify credentials, null, 2
  console.log '------------------------------------'
  # await tradfri.reset()
  # console.log "reset called"
  plug = tradfri.device 'Socket 1'
  plug.on 'changed', (state) =>
    console.log "Plug is now #{if state.isOn then 'on' else 'off'}"
  console.log 'Switching on'
  await plug.switch on
  await sleep 10
  console.log 'Switching off'
  await plug.switch off
  await sleep 10
  blind = tradfri.device 'Bedroom Blind'
  blind.on 'changed', (state, was) =>
    console.log 'STATE', state, was
  pos = if blind.position is 100 then 27 else 100
  console.log "Starting blind moving towards #{pos}"
  await blind.setPosition pos
  await sleep 10
  console.log "Position: #{blind.position}"
  await sleep 30
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
