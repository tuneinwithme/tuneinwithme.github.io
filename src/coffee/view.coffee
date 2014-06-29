'use strict'
app = window.Tuneinwithme

class View extends app.Base

  init: ->

    @on 'ready', (thread) =>
      @bindControls()
      @goToUrlSuggestedRoom thread

    @on 'change-song', (thread) =>
      song = app.Song.current
      thread.stackAndContinue [
        =>
          song.fetchInfo thread
        =>
          @updateInputIfNecessary('.js-input-song', "#{song.name} (#{song.id})")
          $('.album-art').attr 'src', song.image
          $('.background-album-art').css 'background-image', "url(#{song.thumbnail})"
          $('.song-title').text song.name
          $('.song-artist').text song.artistName
          $('.song-album').text song.albumName
          thread.continue()
      ]

    @on 'submit-song', (thread) =>
      @searchAndChangeSong thread, $('.js-input-song').select().val()

    @on 'submit-room', (thread) =>
      @changeRoomById thread, $('.js-input-room').select().val()

    @on 'change-room', (thread) =>
      room = app.Room.current
      @updateInputIfNecessary('.js-input-room', room.id)
      oldRoom = @urlSuggestedRoom()
      if oldRoom != room
        history.pushState({id: room.id}, '', room.id)
      thread.continue()

    @on 'change-url', (thread) =>
      @goToUrlSuggestedRoom thread

  # Binds events to the DOM. Only View should do this.
  onControl: (selector, event, trigger) ->
    $(selector).on event, (evt) =>
      evt.preventDefault()
      @triggerThread trigger

  bindControls: ->
    @onControl '.js-submit-song', 'click', 'submit-song'
    @onControl '.js-submit-room', 'click', 'submit-room'
    @onControl '.js-form-song', 'submit', 'submit-song'
    @onControl '.js-form-room', 'submit', 'submit-room'
    @onControl window, 'popstate', 'change-url'

  changeRoomById: (thread, id) ->
    app.Room.get(id).trigger thread, 'focus'

  searchAndChangeSong: (thread, input) ->
    thread.stackAndContinue [
      =>
        app.Song.search thread, input
      (song) =>
        song.trigger thread, 'focus'
    ]

  goToUrlSuggestedRoom: (thread) ->
    @urlSuggestedRoom().trigger thread, 'focus'
    $('.js-autofocus').select()

  updateInputIfNecessary: (selector, value) ->
    $el = $(selector)
    $el.val value  unless $el.val() is value
    $el.addClass 'flash'
    setTimeout ->
      $el.removeClass 'flash'
    , 0
    $el

  urlSuggestedRoom: ->
    roomId = $(location).attr('pathname').slice 1
    if roomId.length > 0 then return app.Room.get roomId
    else throw new Error 'URL does not suggest default room'

app.view = new View
