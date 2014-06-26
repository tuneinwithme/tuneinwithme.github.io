app = window.Tuneinwithme

class app.Song extends app.Base
  init: (@id) ->
    @fetchedInfo = false

    @on 'focus', =>
      return if @ == @class.current
      @class.previous = @class.current
      @class.current = @
      @class.previous?.trigger 'blur'
      app.Room.current.trigger 'change-song'
      app.view.trigger 'change-song'

      console.log "song: new! #{@id}"

    @on 'blur', =>
      @abortFetch

  abortFetch: (callback) ->
    @fetching?.abort()

  fetchInfo: (callback) ->
    if @fetchedInfo
      callback()
    else
      @abortFetch
      url = 'https://api.spotify.com/v1/tracks?' + $.param {ids: @id.replace('spotify:track:', '')}
      # url = 'https://embed.spotify.com/oembed/?callback=?&' +
      @fetching = $.getJSON url, (data) =>
        track = data['tracks'][0]
        @image = track['album']['images'][0]['url']
        @thumbnail = track['album']['images'][2]['url']
        @albumName = track['album']['name']
        @artistName = track['artists'][0]['name']
        @name = track['name']
        # @thumbnail = data.thumbnail_url.replace('/cover/', '/640/')
        # @title = data.title
        @fetchedInfo = true
        callback()

  @all: {}

  @get: (id) =>
    unless id of @all
      @all[id] = new @(id)
    @all[id]

  @search: (input, callback) =>
    @searchReturningId input, (id) =>
      callback @get id

  @searchReturningId: (input, callback) ->
    if input.search(/^spotify:track:/) == 0
      callback input
      return
    m = input.match(/open.spotify.com\/track\/(\w+)/)
    if m
      callback 'spotify:track:' + m[1]
      return
    url = 'http://ws.spotify.com/search/1/track.json?' + $.param {q: input}
    $.getJSON url, (data) ->
      if data.tracks[0]
        callback data.tracks[0].href
      else
        console.error "No sound found for query \"#{input}\""

  @current: null
  @previous: null
