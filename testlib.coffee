#!/usr/bin/env coffee

coap = require("node-coap-client").CoapClient

HOST = 'tradfri.tallinn.may.be'
# HOST = '192.168.0.25'
ID = require('./identity.json').id

coap.setSecurityParams HOST,
  psk:
    Client_identity: ID

coap.ping "coaps://#{HOST}:5684", 5000
.then (success) =>
  console.log success

  time = new Date
  coap.request "coaps://#{HOST}:5684/15001/65549", 'get', # Buffer.from '65550',
    keepAlive: false
    confirmable: false
    observe: false
  .then (response) =>
    console.log new Date() - time
    response.code = response.code.toString()
    response.payload = response.payload.toString()
    console.log response
    coap.reset HOST
  .catch (err) =>
    console.log 'ERROR', err

