'use strict'
app = window.Tuneinwithme

class app.Room extends app.Base
  init: (@id, @active) ->
    url = "https://tuneinwithme.firebaseio.com/rooms/#{@class.idToSanitized @id}/song/uri"
    console.log "room:", url
    @firedata = new Firebase(url)

    @on 'focus', (thread) =>
      return if @ == @class.current
      @class.previous = @class.current
      @class.current = @

      thread.stack =>
        @active = true
        console.log "room: new! #{@id}"
        app.view.trigger thread, 'change-room'

        @firedata.on 'value', (data) =>
          console.log "room: incoming song data", data.val()
          return unless data and data.val()
          currentSong = app.Song.get data.val()
          currentSong.triggerThread 'focus'

      if @class.previous  then @class.previous.trigger thread, 'blur'
      else thread.continue()


    @on 'blur', (thread) =>
      @active = false
      @firedata.off()
      thread.continue()

    @on 'change-song', (thread) =>
      @firedata.set app.Song.current?.id, thread.continue

  # class methods

  @idToSanitized: (dirty) ->
    encodeURIComponent encodeURIComponent(dirty).replace('.', '%2E')

  @idToDirty: (sanitized) ->
    decodeURIComponent decodeURIComponent sanitized

  @all: {}

  @get: (id) =>
    unless id of @all
      @all[id] = new @(id)
    @all[id]

  @current: null
  @previous: null
