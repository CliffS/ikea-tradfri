#!/usr/bin/env coffee

tradfri = require('node-tradfri')
ID = require('./identity.json').id

trad = tradfri.create
  coapClientPath: '/usr/local/bin/coap-client'
  securityId:     ID
  hubIpAddress:   '192.168.0.25'

do ->
  trad.getDevices()
  .then (devices) =>
    console.log devices.find (el) => el.id is 65548
  .catch (err) =>
    console.log err.toString()
