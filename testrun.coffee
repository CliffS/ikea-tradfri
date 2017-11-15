#!/usr/local/bin/coffee

Tradfri = require './src/Tradfri'
Identity = require './identity'

sleep = (time = 10) ->
  new Promise (resolve, reject) ->
    setTimeout ->
      resolve()
    , time * 1000

tradfri = new Tradfri 'tradfri.tallinn.may.be', Identity.id

tradfri.connect()
.then ->
  await sleep()
  # console.log Array.from tradfri.devices.keys()
  keys = Array.from tradfri.devices.keys()
  console.log keys
  tradfri.reset()
.catch (err) ->
  console.log err

