json.id         @project.id
json.updated_at @project.updated_at
json.title      @project.title
json.notes      @project.notes

json.owner              @project.owner,              :id, :name, :fb_user_picture
json.participated_users @project.participated_users, :id, :name, :fb_user_picture

json.places @project.places
