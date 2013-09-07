app.filter 'searchFriendsStatusFilter', ->

  (user) ->
    if user.added
      if user.pending
        return 'Pending'
      else
        return 'Added'
    else
      return 'Add friend'
