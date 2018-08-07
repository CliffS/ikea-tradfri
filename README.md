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
- [Other Methods and Properties](#other-methods-and-properties)
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

It is safe to call `tradfri.connect()` multiple times or simultaneously
on the same instance.
The first call will perform the actual connect; subsequent calls will
resolve when the connect is completed.

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

There is a third parameter to `new Tradfri`.  This is a boolean
`debug`, defaultng to `false`.  If set to `true`, there will be logging
to `stdout` when devices etc. are updated.

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

- **isOn** *(boolean)*

  Whether this bulb is on or off

- **switchable** *(boolean)*

  Whether this bulb can be switched on and off

- **dimmable** *(boolean)*

  Whether this bulb can be dimmed

- **brightness** *(integer percentage)*

  This can be from 0 to 100.

- **spectrum** *(white|rgb|none)*

  The light spectrum of the bulb: white, rgb or none

- **colour** *(string | percentage)*

  Reading the property will return "white", "warm" or "glow" if its
  value matches one of those settings (1, 62 or 97, respectively) 
  or it will return the current numerical value.

- **color** *(string | percentage)*

  An alternative spelling of colour, q.v..

- **hexcolour** *(hex number)*

  The colour of the bulb expressed as RGB.

- **hue**
- **saturation**

  The hue and saturation of the RGB bulbs (not yet implemented).

The following are the methods to change setings on a bulb:

- **switch()** *(boolean)*

  This is the on-off switch.  It should be sent `true` to turn
  the bulb on or `false` to turn it off.  It will return a promise
  resolving to `true` if the setting was changed or `false` if it
  was not.

- **setBrightness()** *(integer percentage)*

  This can be set from 0 to 100. It will change
  the brightness of the Bulb: 100 is fully bright, 0 will turn the bulb off.
  This will return a promise resolving to `true` if the setting was changed or
  `false` if it was not.

- **setColour()** *(white | warm | glow | integer percentage | hex number )*

  For white spectrum bulbs, this can be set to:
  * "white"
  * "warm" (or "warm white")
  * "glow" (or "warm glow")

  Alternatively it can be set to a number from 1 to 100 where 1 is the coolest
  colour temperature and 100 is the warmest.
  This will return a promise resolving to `true` if the setting was changed or
  `false` if it was not.

  The code is not yet written for RGB bulbs.

- **setColor**

  An alternative spelling of setColour, q.v..

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

  [**NOTE** The format for the changed event since v3.0.0 is
  different and incompatible with previous versions]

  This is emitted with two objects describing the change, whenever a
  device is changed.  Each object will have a `name` key and one
  or more attribute keys: 

  The first object is the new state of the device, the second object
  is the previous state.

```coffeescript
bulb.on changed, (current, previous) ->
  console.log "bulb.#{current.name} has changed:"
  for key, val of current when key isnt 'name'
    console.log "  #{key} was #{previous[key]}, now #{current[key]}"
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

- **isOn** *(boolean)*

  This returns whether the controller believes this group
  to be on or off.

- **scene** *(string)*

  This is the name of the current scene, if any.

- **scenes** *(Array of strings)*

  This will return an array of Scene class objects which are
  available to this group.

- **level** *(integer percentage)*

  Reading this will return the last group value applied.

```coffeescript
group = tradfri.group 'Hallway'
console.log "#{group.name} has the following scenes:"
console.log (scene for scene in group.scenes)
```

The methods are as follows.  Each of these methods returns
a promise that resolves to a boolean.  If true, the change was
made, if false nothing was changed.

- **switch()** *(boolean)*

  Setting this to on (true) will turn on all the bulbs in the
  group.  Setting it to off (false) will turn them off.

- **setLevel()** *(integer percentage)*

  Setting this will set all bulbs in the group to the required level.

```coffeescript
group = tradfri.group 'Hallway'
console.log "#{group.name} is currently at level #{group.level}"
group.level 50
console.log "#{group.name} is now at level #{group.level}"
```

- **setScene()** *(string)*

  This will set the scene for the group, so long
  as the name matches one of the scenes from the group.

```coffeescript
group = tradfri.group 'Hallway'
console.log "#{group.name} is currently set to #{group.scene}"
group.setScene 'Romantic'
```

## Other Methods and Properties
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
connections. Note that it may nevertheless take a few seconds for
the program to end as there may be timers still running.

### devices
```coffeescript
devices = tradfri.devices
```

This will return an array of all the devices that have been
detected.

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

