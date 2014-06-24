class LiveDJ

  bind = (selector, callback) ->
    $(selector).click (evt) =>
      evt.preventDefault()
      callback()

  constructor: ->
    @roomName = undefined
    @currentSongData = undefined
    @lastTrackURL = undefined

    $(document).ready =>
      @changeRoom 'welcometohacktech'
      $('#songinput').select()

      bind '#submitSong', @submitSong
      bind '#submitRoom', @submitRoom


  httpGet: (theUrl) ->
    xmlHttp = null
    xmlHttp = new XMLHttpRequest()
    xmlHttp.open 'GET', theUrl, false
    xmlHttp.send null
    xmlHttp.responseText


  search: (query) ->
    response = @httpGet('http://ws.spotify.com/search/1/track.json?q=' + query)
    res = JSON.parse(response)
    res.tracks[0].href  if res.tracks[0]


  updatePicture: ->
    trackID = @lastTrackURL
    response = $.getJSON 'https://embed.spotify.com/oembed/?url=' + trackID + '&callback=?', (data) ->
      console.log response
      
      # var res = JSON.parse(response);
      bigImage = data.thumbnail_url.replace(/\/cover\//, '/640/')
      $('#albumimage').attr 'src', bigImage
      albumTitle = document.createElement('text')
      albumTitle.innerHTML = data.title
      console.log albumTitle
      $('#titleContainer').html albumTitle
  

  updateInputIfNecessary: (selector, value) ->
    $el = $(selector)
    $el.val value  unless $el.val() is value
    $el.addClass 'flash'
    setTimeout ->
      $el.removeClass 'flash'
    , 0


  changeRoom: (roomName) ->
    roomName = roomName.toLowerCase()
    @currentSongData = new Firebase('https://tuneinwithme.firebaseio.com/rooms/' + roomName + '/song')
    
    # $('#roomName').text(roomName);
    @currentSongData.on 'value', (data) =>
      return unless data and data.val()
      @lastInput = data.val()
      @lastTrackURL = @inputToTrackURL(@lastInput)
      @currentSongData.set (if @lastTrackURL then @lastTrackURL else null)
      @updateInputIfNecessary '#songinput', @lastTrackURL
      @updatePicture()
      @changeBackground()
      console.log 'Track URL updated: ', @lastTrackURL

    @updateInputIfNecessary '#roominput', roomName
    console.log 'room changed to ' + roomName



  
  # var track = models.Track.fromURI( @lastTrackURL );
  # models.player.playTrack(track);

  inputToTrackURL: (input) ->
    return input  if input.search(/^spotify:track:/) is 0
    m = input.match(/open.spotify.com\/track\/(\w+)/)
    return 'spotify:track:' + m[1]  if m
    @search input


  submitSong: =>
    @currentSongData.set $('#songinput').val()
    $('#songinput').select()


  submitRoom: =>
    @changeRoom $('#roominput').val()
    $('#roominput').select()


  changeBackground: ->
    hour = new Date().getHours()
    if hour < 7 or hour > 18
      $('body').removeClass 'day'
      $('body').addClass 'night'
    else
      $('body').removeClass 'night'
      $('body').addClass 'day'

# It's a singleton!
window.LiveDJ = new LiveDJ
