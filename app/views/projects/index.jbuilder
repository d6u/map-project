json.array! @projects do |project|
  json.id         project.id
  json.updated_at project.updated_at
  json.title      project.title
  json.notes      project.notes

  json.owner               project.owner,               :id, :name, :fb_user_picture
  json.participating_users project.participating_users, :id, :name, :fb_user_picture

  json.places project.places
end
