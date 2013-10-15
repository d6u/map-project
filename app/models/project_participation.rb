class ProjectParticipation < ActiveRecord::Base

  belongs_to :project
  belongs_to :user

  validates :project_id, :user_id, :status, presence: true
  validates :user_id, uniqueness: {scope: :project_id}

  validates_each :user_id, :project_id, if: Proc.new {|a| !a.new_record?} do |record, attr, value|
    record.errors[attr] << 'cannot be changed' if record.changed.include? attr.to_s
  end


  # --- Callbacks ---

  after_save    :cache_user_id_on_redis
  after_destroy :remove_cached_user_id_from_redis


  # --- Private ---

  def cache_user_id_on_redis
    if self.status > 0
      $redis.sadd("project:#{self.project_id}:user_ids", self.user_id)
    end
  end


  def remove_cached_user_id_from_redis
    $redis.srem("project:#{self.project_id}:user_ids", self.user_id)
  end


  private :cache_user_id_on_redis, :remove_cached_user_id_from_redis

end
