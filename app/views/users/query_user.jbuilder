json.array! @users do |user|
  json.id              user.id
  json.name            user.name
  json.fb_user_picture user.fb_user_picture
  json.added           @added_friends_id.include?   user.id
  json.pending         @pending_friends_id.include? user.id
end
