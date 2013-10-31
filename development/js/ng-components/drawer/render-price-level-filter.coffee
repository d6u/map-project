app.filter 'renderPriceLevel', ->
  return (priceLevel) ->
    html  = ''
    for i in [0..priceLevel]
      html += '<i class="fa fa-dollar"></i>'
    return html
