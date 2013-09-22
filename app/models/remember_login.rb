require 'securerandom'


class RememberLogin < ActiveRecord::Base

  belongs_to :user

  before_create :generate_codes

  def generate_codes
    self.remember_token = SecureRandom.hex
  end

  private :generate_codes

end
