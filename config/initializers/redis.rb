# --- Init Redis ---

$redis = Redis.new


# --- Cache Project Participations ---

# cache project participating_user ids in Redis
puts "--> Caching project participating_user ids on Redis"

# clean up old caches
old_keys = $redis.keys("project:*:user_ids")
$redis.del(old_keys) if !old_keys.empty?


begin
  # May cause error during migration stage

  # cache new sets
  Project.all.each do |project|
    puts "--> Caching project #{project.id}"
    ids = project.participating_users.pluck(:id) + [project.owner_id]
    $redis.sadd("project:#{project.id}:user_ids", ids) if !ids.empty?
  end

rescue
  puts "--> Error during caching phase. If this happends in migration, everything will be fine. Otherwise you should check."
end
