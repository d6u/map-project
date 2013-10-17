json.array! @users do |user|
  json.id              user.id
  json.name            user.name
  json.profile_picture user.profile_picture
  json.added           @added_friends_id.include?   user.id
  json.pending         @pending_friends_id.include? user.id
end
