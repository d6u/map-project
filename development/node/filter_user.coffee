# Filter user attributes for public use, e.g. generate sender information

module.exports = (user) ->
  return {
    id:   user.id
    name: user.name
    profile_picture: user.profile_picture
  }
