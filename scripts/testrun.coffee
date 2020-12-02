#!/usr/local/bin/coffee
#

# WTF = require 'wtfnode'

require('promise.prototype.finally').shim()
Typeof = require 'typeof'
{Sleep} = require '../src/Utils'

Tradfri = require '../src/Tradfri'
Identity = require '../identity'

sleep = (time = 10) ->
  new Promise (resolve, reject) ->
    setTimeout resolve, time * 1000

# Identity = "hOPupErDoLDw7gDe"
tradfri = new Tradfri 'tradfri.tallinn.may.be', Identity #, true

console.log 'connecting'
tradfri.connect()
.then (credentials) ->
  credentials.id = Identity.id ? Identity
  console.log "Credentials: ", JSON.stringify credentials, null, 2
  console.log '------------------------------------'
  # await tradfri.reset()
  # console.log "reset called"
  console.log tradfri.groups
  bulb = tradfri.device 'TRADFRI bulb 22'
  await bulb.switch on
  console.log 'hotpink'
  await bulb.setColour 'hotpink'
  await sleep 5
  console.log 'red'
  await bulb.setColour 'red'
  console.log 'bright'
  await bulb.setBrightness 100
  await sleep 5
  await bulb.setBrightness 30
  # await sleep 5
  console.log 'blue'
  await bulb.setColour 0x0000ff
  await sleep 5
  console.log 'green'
  await bulb.setColour 'green'
  await sleep 5
  await bulb.switch off
  ###
  console.log (g.name for g from tradfri.groups)
  console.log tradfri.scenes
  console.log 'setting "test off"'
  await tradfri.setScene 'test off'
  await sleep 20
  console.log 'setting "testing"'
  await tradfri.setScene 'testing'
  await sleep 20

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
