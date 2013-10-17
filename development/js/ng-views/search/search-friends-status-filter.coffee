app.filter 'searchFriendsStatusFilter', ->

  return (user) ->
    if user.get('added')
      if user.get('pending')
        return 'Pending'
      else
        return 'Added'
    else
      return 'Add friend'
