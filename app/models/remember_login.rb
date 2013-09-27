require 'securerandom'


class RememberLogin < ActiveRecord::Base

  belongs_to :user

  before_create :generate_code

  def generate_code
    self.remember_token = SecureRandom.hex
  end

  private :generate_code

end
