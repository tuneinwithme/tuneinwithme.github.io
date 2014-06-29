'use strict'
app = window.Tuneinwithme

class app.Song extends app.Base
  init: (@id) ->
    @fetchedInfo = false
    @shortId = @id.replace('spotify:track:', '')

    @on 'focus', (thread) =>
      return thread.continue()  if @ == @class.current
      @class.previous = @class.current
      @class.current = @
      thread.stackAndContinue [
        =>
            if @class.previous  then @class.previous.trigger thread, 'blur'
            else thread.continue()
        =>
            app.Room.current.trigger thread, 'change-song'
        =>
            app.view.trigger thread, 'change-song'
      ]
      console.log "song: new! #{@id}"

    @on 'blur', (thread) =>
      @abortFetch thread

  abortFetch: (thread) ->
    @fetchRequest?.abort()
    thread.continue()

  fetchInfo: (thread) ->
    if @fetchedInfo  then thread.continue()
    else
      @abortFetch
      url = 'https://api.spotify.com/v1/tracks?' + $.param {ids: @shortId}
      @fetchRequest = $.getJSON url, (data) =>
        track = data['tracks'][0]
        @image = track['album']['images'][0]['url']
        @thumbnail = track['album']['images'][2]['url']
        @albumName = track['album']['name']
        @artistName = track['artists'][0]['name']
        @name = track['name']
        @fetchedInfo = true
        thread.continue()

  # class methods

  @all: {}

  @get: (id) =>
    unless id of @all  then @all[id] = new @(id)
    @all[id]

  @search: (thread, input) =>
    thread.stackAndContinue [
      =>
        @searchGettingId thread, input
      (id) =>
        thread.continue @get id
    ]

  @searchGettingId: (thread, input) =>
    if input.search(/^spotify:track:/) == 0
      return thread.continue input
    else if (m = input.match(/open.spotify.com\/track\/(\w+)/))
      return thread.continue 'spotify:track:' + m[1]
    url = 'http://ws.spotify.com/search/1/track.json?' + $.param {q: input}
    $.getJSON url, (data) ->
      if data.tracks[0]
        return thread.continue data.tracks[0].href
      else
        throw new Error "No sound found for query \"#{input}\""

  @current: null
  @previous: null
