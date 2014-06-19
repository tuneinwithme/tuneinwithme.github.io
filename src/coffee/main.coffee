LiveDJ = (->

  self = {}

  self.roomName = undefined
  self.currentSongData = undefined
  self.lastTrackURL = undefined

  self.httpGet = (theUrl) ->
    xmlHttp = null
    xmlHttp = new XMLHttpRequest()
    xmlHttp.open 'GET', theUrl, false
    xmlHttp.send null
    xmlHttp.responseText


  self.search = (query) ->
    response = self.httpGet('http://ws.spotify.com/search/1/track.json?q=' + query)
    res = JSON.parse(response)
    res.tracks[0].href  if res.tracks[0]


  self.updatePicture = ->
    trackID = self.lastTrackURL
    response = $.getJSON('https://embed.spotify.com/oembed/?url=' + trackID + '&callback=?', (data) ->
      console.log response
      
      # var res = JSON.parse(response);
      bigImage = data.thumbnail_url.replace(/\/cover\//, '/640/')
      $('#albumimage').attr 'src', bigImage
      albumTitle = document.createElement('text')
      albumTitle.innerHTML = data.title
      console.log albumTitle
      $('#titleContainer').html albumTitle
      return
    )
    return


  self.updateInputIfNecessary = (selector, value) ->
    $el = $(selector)
    $el.val value  unless $el.val() is value
    $el.addClass 'flash'
    setTimeout (->
      $el.removeClass 'flash'
      return
    ), 0
    return


  self.changeRoom = (roomName) ->
    roomName = roomName.toLowerCase()
    self.currentSongData = new Firebase('https://tuneinwithme.firebaseio.com/rooms/' + roomName + '/song')
    
    # $('#roomName').text(roomName);
    self.currentSongData.on 'value', self.onDataChange
    self.updateInputIfNecessary '#roominput', roomName
    console.log 'room changed to ' + roomName
    return


  self.onDataChange = (data) ->
    return unless data and data.val()
    self.lastInput = data.val()
    self.lastTrackURL = self.inputToTrackURL(self.lastInput)
    self.currentSongData.set (if self.lastTrackURL then self.lastTrackURL else null)
    self.updateInputIfNecessary '#songinput', self.lastTrackURL
    self.updatePicture()
    self.changeBackground()
    console.log 'Track URL updated: ', self.lastTrackURL
    return

  
  # var track = models.Track.fromURI( self.lastTrackURL );
  # models.player.playTrack(track);

  self.inputToTrackURL = (input) ->
    return input  if input.search(/^spotify:track:/) is 0
    m = input.match(/open.spotify.com\/track\/(\w+)/)
    return 'spotify:track:' + m[1]  if m
    self.search input


  self.submitSong = ->
    self.currentSongData.set $('#songinput').val()
    $('#songinput').select()
    return

  $('#submitSong').click (evt) ->
    evt.preventDefault()
    self.submitSong()


  self.submitRoom = ->
    self.changeRoom $('#roominput').val()
    $('#roominput').select()
    return

  $('#submitRoom').click (evt) ->
    evt.preventDefault()
    self.submitRoom()


  self.init = ->
    self.changeRoom 'welcometohacktech'
    $('#songinput').select()
    return


  self.changeBackground = ->
    hour = new Date().getHours()
    if hour < 7 or hour > 18
      $('body').removeClass 'day'
      $('body').addClass 'night'
    else
      $('body').removeClass 'night'
      $('body').addClass 'day'
    return


  self
)()

$(document).ready LiveDJ.init