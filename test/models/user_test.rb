require 'test_helper'


class UserTest < ActiveSupport::TestCase

  test "should generate salt and hash when user create" do
    user = User.new({email: 'anqi@email.com', password: '12345678', name: 'Anqi Lu'})
    assert user.save
    assert user.password_salt
    assert user.password_hash
  end

  test "should not authorize user" do
    assert !User.authorize_with_email('daiweilu@email.com', '87654321')
    assert !User.authorize_with_email('someone@email.com', '12345678')
    assert !User.authorize_with_email({email: 'daiweilu@email.com', password: '87654321'})
    assert !User.authorize_with_email({email: 'someone@email.com', password: '12345678'})
  end

  test "should authorize user" do
    assert User.authorize_with_email('daiweilu@email.com', '12345678')
    assert User.authorize_with_email({email: 'daiweilu@email.com', password: '12345678'})
  end

  # TODO: add facebook testing

end
