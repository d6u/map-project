# --- Init Redis ---

$redis = Redis.new


# --- Cache Project Participations ---

# cache project participating_user ids in Redis
puts "--> Caching project participating_user ids on Redis"

# clean up old caches
$redis.del( $redis.keys("project:*:user_ids") )

# cache new sets
Project.all.each do |project|
  puts "--> Caching project #{project.id}"
  ids = project.participating_users.pluck(:id) + [project.owner_id]
  if !ids.empty?
    $redis.sadd("project:#{project.id}:user_ids", ids)
  end
end
