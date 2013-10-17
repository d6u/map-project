json.id         @project.id
json.updated_at @project.updated_at
json.title      @project.title
json.notes      @project.notes

json.owner               @project.owner,               :id, :name, :profile_picture
json.participating_users @project.participating_users, :id, :name, :profile_picture

json.places @project.places
