app.directive 'mdPlacesListSortable', ['MapPlaces', (MapPlaces) ->

  link: (scope, element, attrs, MdPlacesListSortableCtrl) ->

    angularComment = null

    element.sortable({
      # appendTo: document.body # append to body will disable list scroll
      axis:     'y'
      cursor:   'move'
      distance: 5
      handle:   '.md-places-item-name a.reorder'
      placeholder: 'md-drawer-saved-place-sort-placeholder'

      start: (event, ui) ->
        allElements = element.contents()
        itemIndex   = null
        allElements.each (index) -> itemIndex = index if this == ui.item[0]
        angularComment = allElements[itemIndex + 2]

      update: (event, ui) ->
        element.children().each (i) ->
          $(this).scope().place.set({order: i})
        # move the comment belongs to previous element to its place
        $( ui.item[0].previousSibling ).after( ui.item[0].nextSibling )
        # append comment belongs to sorted item after it
        ui.item.after(angularComment)
        MapPlaces.sort()
    })
]
