Accessory = require './Accessory'
Colours   = require 'colornames'
{Sleep} = require './Utils'

class Bulb extends Accessory

  # Add the 'property' definition here as we can't inherit from it
  @property: (name, accessors) ->
    Object.defineProperty @::, name, accessors

  constructor: (device) ->
    super device
    light = device.lightList[0]
    @brightness   =  light.dimmer
    @isOn         =  light.onOff
    @transition   =  light.transitionTime
    @switchable   =  light.isSwitchable
    @dimmable     =  light.isDimmable
    @spectrum     =  light.spectrum
    @temperature  =  light.colorTemperature
    @hexcolour    =  light.color
    @hue          =  light.hue          if light.hue?
    @saturation   =  light.saturation   if light.saturation?
    #console.log Colours.all()
    #process.exit 1

  operate: (obj) ->
    tradfri = @device.client
    tradfri.operateLight @device, obj

  switch: (onOff) ->
    @operate onOff: onOff
    .then (ok) =>
      @ison = onOff
      ok

  setBrightness: (level) ->
    @operate dimmer: level
    .then (ok) =>
      @brightness = level
      ok

  @property 'level',
    get: ->
      @brightness
    set: (level) ->
      @setBrightness level

  colours =
    white: 'f5faf6'
    warm:  'f1e0b5'
    glow:  'efd275'

  setColour: (colour) ->
    Promise.resolve()
    .then =>
      switch @spectrum
        when 'white'    # cold/warm bulbs
          switch colour
            when 'white'
              temp = 1
            when 'warm', 'warm white'
              temp = 62
            when 'glow', 'warm glow'
              temp = 97
            else
              temp = parseInt colour
              throw new Error "Unknown colour of #{colour}" unless 0 <= temp <= 100   # 0 to 100 inclusive
          @operate colorTemperature: temp
          .then (ok) =>
            @temperature = temp
            ok
        when 'rgb'
          if typeof colour is 'string'
            console.log "Colour #{colour} is #{Colours(colour)}"
            hexColour = Colours(colour)?.substr 1
            throw new Error "Unknown colour: #{colour}" unless hexColour?
          else
            hexColour = ('000000' + colour.toString 16).substr -6
          @operate color: hexColour
          .then (ok) =>
            @hexcolour = hexColour
            await Sleep .6
            ok
        when 'none' # do nothing
        else
          throw new Error "Unknown bulb spectrum: #{@spectrum}"

  setColor: (colour) ->
    @setColour colour

  @property "colour",
    get: ->
      switch @spectrum
        when 'white'
          switch parseInt @temperature
            when 1
              'white'
            when 62
              'warm'
            when 97
              'glow'
            else
              @temperature
        else
          return @hexcolour
    set: (colour) ->
      @setColour colour

  @property 'color',
    get: ->
      @colour
    set: (colour) ->
      @setColour colour






module.exports = Bulb
