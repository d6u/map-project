require 'securerandom'


class Invitation < ActiveRecord::Base

  belongs_to :user
  belongs_to :project

  before_create :generate_code

  def generate_code
    self.code = SecureRandom.hex
  end
end
