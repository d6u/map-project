app.directive 'mdPlacesListSortable', ['MapPlaces', (MapPlaces) ->

  link: (scope, element, attrs, MdPlacesListSortableCtrl) ->

    element.sortable({
      appendTo: document.body
      helper:   'clone'
      cursor:   'move'
      distance: 5
      handle:   '.md-places-item-image'

      update: (event, ui) ->
        element.children().each (i, li) ->
          $(li).scope().place.set({order: i})
        MapPlaces.sort()
    })
]
