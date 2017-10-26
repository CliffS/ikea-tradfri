#!/usr/bin/env coffee

coap = require("node-coap-client").CoapClient

HOST = 'tradfri.tallinn.may.be'
# HOST = '192.168.0.25'
ID = require('./identity.json').id

coap.setSecurityParams HOST,
  psk:
    Client_identity: ID

time = undefined
coap.ping "coaps://#{HOST}:5684", 5000
.then (success) =>
  console.log success

  time = new Date
  ###
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
  ###
  job =
    '3311': [
      '5850': 1
    ]
  payload = Buffer.from JSON.stringify job
  console.log payload.toString()
  coap.request "coaps://#{HOST}:5684/15001/65548", 'put', payload,
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
  console.log err
  coap.reset HOST

