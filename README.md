# ikea-tradfri
A library to access the Ikea Trådfri lighting system without needing
to call a separate binary

Please note that this library should be considered as an early beta
currently.  Things may change.  They may even start working.

## Example

Currently the examples are in Coffeescript.  I will add Javascript
examples later.  Coffeescript is not necessary to be able to use this
library, it will work with any language that transpiles to Javascript.

```coffeescript
Tradfri  = require 'ikea-tradfri'
Identity = require './Identity'     # Identity.json is private credentials

tradfri = new Tradfri 'device.example.com', Identity
tradfri.connect()
.then (credentials) ->
  # store the credentials if necessary
  group4 = tradfri.group 'TRADFRI group 4'  # find the group
  group4.scene = 'RELAX'                    # Set the scene (mood)
  bulb = tradfri.device 'Standard Lamp'     # Find a bulb
  bulb.colour = 'white'                     # Set the cool colour
  bulb.level  = 50                          # Set half brightness
.catch (err) ->
  console.error "Failed to connect: #{err}"
```

## Table of Contents

- [Rationale](#rationale)
- [Installation](#installation)
- [Connecting to the Trådfri Controller](#connecting-to-the-tr%C3%A5dfri-controller)
  - [First time](#first-time)
  - [Subsequent connect calls](#subsequent-connect-calls)
- [Devices](#devices)
  - [Getting a Device](#getting-a-device)
  - [Device Properties](#device-properties)
  - [Bulb](#bulb)
  - [Remote and Sensor](#remote-and-sensor)
  - [Events](#events)
- [Groups](#groups)
  - [Getting a Group](#getting-a-group)
  - [Group Properties](#group-properties)
- [Other Methods](#other-methods)
- [Issues](#issues)
- [Licence](#licence)


## Rationale

This library is designed to abstract away the complexities of both
[CoAP] and the excellent underlying libraries, [node-tradfri-client]
and [node-coap-client], both by the amazing [AlCalzone].

Currently it assumes that your Trådfri controller is set up using another
tool, probably the Ikea app for Android or iPhone. 

[CoAP]: http://coap.technology/
[node-tradfri-client]: https://github.com/AlCalzone/node-tradfri-client
[node-coap-client]: https://github.com/AlCalzone/node-coap-client
[AlCalzone]: https://www.npmjs.com/~alcalzone
[issues]: https://github.com/CliffS/ikea-tradfri/issues
[glpl]: https://www.gnu.org/licenses/lgpl-3.0.en.html
[Ikea]: http://www.ikea.com/

## Installation

    npm install ikea-tradfri

## Connecting to the Trådfri Controller

There are two ways to connect. The first time, you should use
the security code printed on the base of the controller.  You should then
save the returned credentials and always use these credentials when
connecting in the future.

**NB:** If you continue to use the
security code, the controller will gradually forget about any
other connected apps and these will need to reauthenticate.

The host can be a domain name such as `device.example.com`
or a dotted IP address such as `192.168.1.20`.

`tradfri.connect()` returns  Promise.  You should wait for
the promise to resolve before continuing.  This can be done
with a `.then()` or by `await`ing the result.  Either way you
should `catch` any error.

### First time

  The first time you connect, you should use the code from the bottom
of the controller:

```coffeescript
Identity = 'mOPupErDolDw5gDf'
tradfri = new Tradfri 'device.example.com', Identity
tradfri.connect()
.then (credentials) ->
  # Save the credentials
.catch (err) ->
  console.error err
  process.exit 1
```

`credentials` will be an object containing two keys, `identity` and `psk`.
This object should be stored, perhaps as a JSON file, for future use.

### Subsequent connect calls

Subsequently the call could look like this:

```coffeescript
Identity = require './identity'  # stored in identity.json
tradfri = new Tradfri 'device.example.com', Identity
try
  await tradfri.connect()
catch err
  console.error err
  process.exit 1
```

All example code below assumes you have the `tradftri` variable above.

## Devices

There are currently three types of device:

<dl>
<dt>Bulb</dt><dd>A lightbulb, panel etc.</dd>
<dt>Remote</dt><dd>A remote control device</dd>
<dt>Sensor</dt><dd>A movement sensor</dd>
</dl>

For this library to work correctly, each device and group should be
distinctly named as the library works exclusively from those names.

The Trådfri controller only permits Bulbs to be tracked.  There seems
to be no way to know when a Remote has been activated, other than 
by tracking a connected Bulb.

### Getting a Device

Using the `tradfri` variable created
above, you call `tradfi.device(name)` where `name` is the name of the device
you are looking for.  It will return the approriate class for `name` or
`undefined` if it is not found.

`name` can also be an array of device names.  In this case,
`trafri.device(array)` will return an array of all the devices matched or an
empty array if none are found.  Currently there is no provision
for wildcards.

### Device Properties

These are the properties that are common to all devices.  All these properties
should be considered read-only. Changing them will currently not be fed
back to the controller.

- **id** *(integer)*

  This is the internal ID used by the controller.
  It is not usually necessary to use this ID in this library.

- **name** *(string)*

  This is the name of the device and is the usual way to access it in this
  library.

- **type** *(string)*

  This will be one of Bulb, Remote or Sensor.

- **alive** *(boolean)*

  This indicates whether or not the Ikea controller believes this device to be
powered on.

### Bulb

These are the bulb-specific properties (read-only):

- **switchable** *(boolean)*

  Whether this bulb can be switched on and off

- **dimmable** *(boolean)*

  Whether this bulb can be dimmed

- **spectrum** *(white|rgb|none)*

  The light spectrum of the bulb: white, rgb or none

- **hexcolour** *(hex number)*

  The colour of the bulb expressed as RGB.

- **hue**
- **saturation**

  The hue and saturation of the RGB bulbs (not yet implemented).

The following are the read-write properties of a Bulb:

- **switch** *(boolean)*

  This is the on-off switch.  Reading it will get the state of the
  Bulb.  Writing to it will turn the bulb on or off.

```coffeescript
bulb = tradfri.device 'Bulb number 1'
console.log "#{bulb.name} is currently #{if bulb.switch then 'on' else 'off'}"
bulb.switch = on
```

- **level** *(integer percentage)*

  This can be set from 0 to 100.  Reading it will return
  the current brightness of the Bulb.  Writing to it will change
  the brightness of the Bulb: 100 is fully bright, 0 will turn the bulb off.

```coffeescript
bulb = tradfri.device 'Bulb number 1'
console.log "#{bulb.name} is currently at level #{bulb.level}"
bulb.level = 50
```

- **colour** *(white | warm | glow | integer percentage | hex number )*

  For white spectrum bulbs, this can be set to:
  * "white"
  * "warm" (or "warm white")
  * "glow" (or "warm glow")

  Alternatively it can be set to a number from 1 to 100 where 1 is the coolest
  colour temperature and 100 is the warmest.

  Reading the property will return "white", "warm" or "glow" if its
  value matches one of those settings (1, 62 or 97, respectively) 
  or it will return the current numerical value.

```coffeescript
bulb = tradfri.device 'Bulb number 1'
console.log "#{bulb.name} colour is currently #{bulb.colour}"
bulb.colour = 'white'
```

  The code is not yet written for RGB bulbs.

- **color**

  An alternative spelling of colour, q.v..

### Remote and Sensor

Currently these only have the common properties described
[above](#device-properties).  It is not currently possible to detect
changes when a remote is pressed or a sensor triggered owing to
a lack of reporting by the Trådfri controller.

### Events

All three device types are event emitters although Remotes and
Sensors do not seem to emit events when they are triggered.

Currently only two events are emitted:

- **deleted**

  This is emitted if the device has been deleted from the
  controller. It is passed a parameter of the Device's name.

```coffeescript
device.on "deleted", (name) ->
  console.log "device.#{name} has just been deleted"
```

- **changed**

  This is emitted with an object describing the change, whenever a
  device is changed.  The object will have two
  keys: 
  
  * name    - the name of the device
  * changed - an object containing one or more attributes as keys,
    where each value is an object containing `old` and `new`, describing
    the change.

```coffeescript
bulb.on changed, (changes) ->
  console.log "bulb.#{changes.name} has changed:"
  console.log "  #{k} was #{v.old}, now #{v.new}" for k, v of changes.changed
```
## Groups

### Getting a Group

Getting a group is similar to getting a device.  Using the `tradfri`
variable, you call `tradfri.group(name)` where `name` is the name
of the group you are looking for.  It will return `undefined` if
not found.

### Group Properties

The read-only properties for a group are:

- **id** *(integer)*

  This is the internal ID used by the controller.

- **name** *(string)*

  This is the name of the group and is the usual way to access
  it in this library.

- **scenes** *(Array of strings)*

  This will return an array of Scene class objects which are
  available to this group.

```coffeescript
group = tradfri.group 'Hallway'
console.log "#{group.name} has the following scenes:"
console.log scene for scene in group.scenes
```

The writable properties are as follows:

- **switch** *(boolean)*

  Setting this to on (true) will turn on all the bulbs in the
  group.  Setting it to off (false) will turn them off.
  Reading this will give the current group value which may or
  may not reflect the state of the bulbs.

```coffeescript
group = tradfri.group 'Hallway'
console.log "#{group.name} is currently #{if group.switch then 'on' else 'off'}"
group.switch = on
```

- **level** *(integer percentage)*

  Setting this will set all bulbs in the group to the required level.
  Reading it will return the last group value applied.

```coffeescript
group = tradfri.group 'Hallway'
console.log "#{group.name} is currently at level #{group.level}"
group.level - 50
```

- **scene** *(string)*

  Reading this will return the name of the currently set scene, if any.
  Setting this property will set the scene for the group, so long
  as the name matches one of the scenes from the group.

```coffeescript
group = tradfri.group 'Hallway'
console.log "#{group.name} is currently set to #{group.scene}"
group.scene = 'Romantic'
```

## Other Methods
### reset()

```coffeescript
tradfri.reset()
```

This can be used to reset the connection.

### close()
```coffeescript
tradfri.close()
```

This should be called before ending the program so that the gateway
can clean up its resources and so that the program will close its
connections.

## Acknowlegements

Many thanks to [AlCalzone] for his excellent libraries, without which
this library would have been infinitely harder to write.

I have no affiliation to [Ikea] and this library is not approved or
endorsed in any way by Ikea.

## Issues

Please report all issues via the [Github issues page][issues].

## Licence

This library is currently offered under version 3 of the
[GNU Lesser General Public Licence][glpl].  If you need a different
licence, please [contact me](mailto:clif@may.be).

