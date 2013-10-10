require 'securerandom'


class RememberLogin < ActiveRecord::Base

  belongs_to :user

  validates :remember_token, :user_id, presence: true
  validates :remember_token, uniqueness: {scope: :user_id}

  validates_each :user_id, :remember_token, if: Proc.new {|a| !a.new_record?} do |record, attr, value|
    record.errors[attr] << 'cannot be changed' if record.changed.include? attr.to_s
  end

  after_initialize :generate_code

  def generate_code
    self.remember_token = SecureRandom.hex if self.new_record?
  end

  private :generate_code

end
