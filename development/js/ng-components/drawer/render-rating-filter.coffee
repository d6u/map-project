app.filter 'renderRating', ->
  return (rating) ->
    level = Math.round(rating)
    html  = ''
    for i in [0..4]
      if i <= level
        html += '<i class="fa fa-star"></i>'
      else
        html += '<i class="fa fa-star-o"></i>'
    return html
