Accessory = require './Accessory'

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

  operate: (obj) ->
    tradfri = @device.client
    tradfri.operateLight @device, obj

  @property "switch",
    set: (onOff) ->
      @device.toggle onOff
      .then (ok) =>
        @ison = onOff if ok
      .catch (err) =>
    get: ->
      @isOn

  @property "level",
    set: (level) ->
      @operate dimmer: level
      .then (ok) =>
        @brightness = level if ok
      .catch (err) =>
    get: ->
      @brightness

  colours =
    white: 'f5faf6'
    warm:  'f1e0b5'
    glow:  'efd275'
      
  @property "colour",
    set: (colour) ->
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
          @operate
            colorTemperature: temp
          .then (ok) =>
            @temperature = temp if ok
          .catch (err) =>
        when 'rgb'
          throw new Error 'Not written yet'
        when 'none'
          # do nothing
        else
          throw new Error "Unknown bulb spectrum: #{@spectrum}"
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

  @property 'color',
    set: (color) ->
      @colour = color
    get: ->
      @colour






module.exports = Bulb
