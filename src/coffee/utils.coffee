app = window.Tuneinwithme = {}

class app.Base
  constructor: ->
    @bindings = {}
    @init.apply(@, arguments)
    @class = @constructor

  init: ->
    throw new Error('Base is abstract')

  on: (event, callback) ->
    unless event of @bindings
      @bindings[event] = []
      # console.log "bindings: creating new event #{event}"
    @bindings[event].push callback

  trigger: (event) ->
    return unless event of @bindings
    for callback in @bindings[event]
      callback()
