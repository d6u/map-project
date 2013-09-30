class ProjectParticipation < ActiveRecord::Base

  belongs_to :project
  belongs_to :user

  validates :project_id, :user_id, :status, presence: true
  validates :user_id, uniqueness: {scope: :project_id}

  validates_each :user_id, :project_id, if: Proc.new {|a| !a.new_record?} do |record, attr, value|
    record.errors[attr] << 'cannot be changed' if record.changed.include? attr.to_s
  end

end
