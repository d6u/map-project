app.directive 'mdPlacesListSortable', ['MapPlaces', (MapPlaces) ->

  link: (scope, element, attrs, MdPlacesListSortableCtrl) ->

    element.sortable({
      # appendTo: document.body # append to body will disable list scroll
      axis:     'y'
      cursor:   'move'
      distance: 5
      handle:   '.md-places-item-name a.reorder'
      placeholder: 'md-drawer-saved-place-sort-placeholder'

      update: (event, ui) ->
        element.children().each (i) ->
          $(this).scope().place.set({order: i})
        MapPlaces.sort()
    })
]
