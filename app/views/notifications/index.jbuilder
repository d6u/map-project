json.array! @notifications do |followship|
  json.type   'addFriendRequest'
  json.sender do
    json.id              followship.user.id
    json.name            followship.user.name
    json.fb_user_picture followship.user.fb_user_picture
  end
  json.receivers_ids nil
  json.body do
    json.friendship_id followship.id
  end
end
