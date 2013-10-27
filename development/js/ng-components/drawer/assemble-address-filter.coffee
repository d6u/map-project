app.filter 'assembleAddress', ->
  return (place) ->
    if place.has('address_components')
      components = _.filter place.get('address_components'), (component) ->
        for type in component.types
          return false if type == 'administrative_area_level_2'
        return true

      a    = _.pluck(components, 'short_name')
      html = "#{a[0]} #{a[1]}<br/>#{a[2]}, #{a[3]}, #{a[4]} #{a[5]}"
    else
      html = place.get('formatted_address')
    return html;
