# Filter user attributes for public use, e.g. generate sender information

module.exports = (user) ->
  return {
    id:   user.id
    name: user.name
    fb_user_picture: user.fb_user_picture
  }
