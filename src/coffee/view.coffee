app = window.Tuneinwithme

class View extends app.Base

  init: ->
    @on 'ready', =>
      @bindControls()
      @goToUrlSuggestedRoom()

    @on 'change-song', =>
      song = app.Song.current
      song.fetchInfo =>
        @updateInputIfNecessary('.js-input-song', "#{song.name} (#{song.id})")
        $('.album-art').attr 'src', song.image
        $('.background-album-art').css 'background-image', "url(#{song.thumbnail})"
        $('.song-title').text song.name
        $('.song-artist').text song.artistName
        $('.song-album').text song.albumName

    @on 'change-room', =>
      room = app.Room.current
      @updateInputIfNecessary('.js-input-room', room.id)
      @urlSuggestedRoom (oldRoom) =>
        if oldRoom != room
          history.pushState({id: room.id}, '', room.id)

  onControl: (selector, event, callback) ->
    $(selector).on event, (evt) ->
      evt.preventDefault()
      callback()

  bindControls: ->
    submitSong = => @searchAndChangeSong $('.js-input-song').select().val()
    submitRoom = => @changeRoomById $('.js-input-room').select().val()
    @onControl '.js-submit-song', 'click', submitSong
    @onControl '.js-submit-room', 'click', submitRoom
    @onControl '.js-form-song', 'submit', submitSong
    @onControl '.js-form-room', 'submit', submitRoom

    @onControl window, 'popstate', @goToUrlSuggestedRoom


  changeRoomById: (id) ->
    app.Room.get(id).trigger 'focus'

  searchAndChangeSong: (input) ->
    app.Song.search input, (song) ->
      song.trigger 'focus'

  goToUrlSuggestedRoom: =>
    @urlSuggestedRoom (room) ->
      room.trigger 'focus'
    $('.js-autofocus').select()

  updateInputIfNecessary: (selector, value) ->
    $el = $(selector)
    unless $el.val() is value
      $el.val value
    $el.addClass 'flash'
    setTimeout ->
      $el.removeClass 'flash'
    , 0
    $el

  urlSuggestedRoom: (callback) ->
    id = $(location).attr('pathname').slice 1
    if id.length > 0
      callback app.Room.get id
    else
      console.error 'url does not suggest default room'

app.view = new View
