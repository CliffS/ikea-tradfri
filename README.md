# ikea-tradfri
A library to access the Ikea Trådfri lighting system without needing
to call a separate binary

## Example

Currently the examples are in Coffeescript.  I will add Javascript
examples later.

```coffeescript
Tradfri  = require 'ikea-tradfri'
Identity = require './Identity'     # Identity.json is private credentials

tradfri = new Tradfri 'device.example.com', Identity
tradfri.connect()
.then (credentials) ->
  # store the credentials if necessary
  group4 = tradfri.group 'TRADFRI group 4'  # find the group
  group4.scene = 'RELAX'                    # set the scene (mood)
  bulb = tradfri.device 'Standard Lamp'     # find a bulb
  bulb.colour = 'white'                     # Set the cool colour
  bulb.level  = 50                          # Half brightness
```


