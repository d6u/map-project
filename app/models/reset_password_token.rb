class ResetPasswordToken < ActiveRecord::Base

  belongs_to :user

  validates :reset_token, :user_id, presence: true
  validates :reset_token, uniqueness: true

end
