app.filter 'renderPhoto', ->
  return (place) ->
    html = ''
    if place.has('photos')
      for i in [0..2]
        if place.get('photos')[i]?
          url   = place.get('photos')[i].getUrl({maxWidth: 90})
          html += "<img src=\"#{url}\" />"
    return html
