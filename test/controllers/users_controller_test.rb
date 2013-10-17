require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  # --- Email ---
  # login
  test 'should not login becasue password was wrong' do
    params = {
      user: {
        email: 'daiweilu@email.com',
        password: '87654321'
      }
    }
    post(:email_login, params)
    assert_response 401
  end

  test 'should not login becasue email was wrong' do
    params = {
      user: {
        email: 'anqi@email.com',
        password: '12345678'
      }
    }
    post(:email_login, params)
    assert_response 401
  end

  test 'should login' do
    params = {
      user: {
        email: 'daiweilu@email.com',
        password: '12345678'
      }
    }
    post(:email_login, params)
    assert_response 200
    assert_not_nil session[:user_id]
  end

  # register
  test 'should register' do
    params = {
      user: {
        name: 'Anqi Lu',
        email: 'anqi@email.com',
        password: '01234567',
        password_confirmation: '01234567'
      }
    }
    post(:email_register, params)
    assert_response 200
    ap MultiJson.load(@response.body)
  end

  test 'should not register becasue password and password_confirmation not match' do
    params = {
      user: {
        name: 'Anqi Lu',
        email: 'anqi@email.com',
        password: '01234567',
        password_confirmation: '12345678'
      }
    }
    post(:email_register, params)
    assert_response 406

    response_json = MultiJson.load(@response.body)
    assert response_json['error']
    assert_equal response_json['error_code'], 'US000'
  end

end
