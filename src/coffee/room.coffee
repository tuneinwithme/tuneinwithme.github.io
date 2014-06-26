app = window.Tuneinwithme

class app.Room extends app.Base
  init: (@id, @active) ->
    url = "https://tuneinwithme.firebaseio.com/rooms/#{@id}/song/uri"
    console.log "room:", url
    @firedata = new Firebase(url)

    @on 'focus', =>
      return if @ == @class.current
      @class.previous = @class.current
      @class.current = @
      @class.previous?.trigger 'blur'
      app.view.trigger 'change-room'

      console.log "room: new! #{@id}"

      @active = true
      @firedata.on 'value', (data) =>
        console.log "room: incoming song data", data.val()
        return unless data and data.val()
        currentSong = app.Song.get data.val()
        currentSong.trigger 'focus'

    @on 'blur', =>
      @active = false
      @firedata.off()

    @on 'change-song', =>
      @firedata.set app.Song.current?.id

  @all: {}

  @get: (id) =>
    unless id of @all
      @all[id] = new @(id)
    @all[id]

  @current: null
  @previous: null
