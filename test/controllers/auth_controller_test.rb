require 'test_helper'


class AuthControllerTest < ActionController::TestCase

  def setup
    @controller = Api::AuthController.new
  end


  # --- login_status ---

  # no session no cookies
  test 'should get 404' do
    get :login_status
    assert_response 404
  end

  # invalid session
  test 'should remove session' do
    get :login_status, nil, {user_id: 0}
    assert_response 404
    assert_nil session[:user_id]
  end

  # valid session
  test 'should return user data' do
    user = User.find_by_email('daiweilu@email.com')
    get :login_status, nil, {user_id: user.id}
    assert_response 200, 'response OK'
    assert_equal(user.to_json(only: [:id, :name, :profile_picture, :email]),
      @response.body, 'response body as expected')
    refute_nil session[:user_id], 'session not nil'
  end

  # invalid cookies
  test 'should remove cookies' do
    cookies[:user_id] = '0'
    get :login_status
    assert_response 404
    assert_nil cookies[:user_id]

    cookies[:user_token] = '123456'
    get :login_status
    assert_response 404
    assert_nil cookies[:user_token]

    cookies[:user_token] = '123456'
    cookies[:user_id] = '0'
    get :login_status
    assert_response 404
    assert_nil cookies[:user_id]
    assert_nil cookies[:user_token]
  end

  # valid cookies
  # facebook
  test 'should response facebook' do
    # user = User.find_by_email('daiweilu@email.com')
    # RememberLogin.create
    # remember_login = RememberLogin.new({login_type: 1})
    # user.remember_logins << remember_login
    # assert remember_login.save, remember_login.user_id

    # ap user.remember_logins
    # cookies[:user_id]    = remember_login.user_id.to_s
    # cookies[:user_token] = remember_login.remember_token.to_s
    # get :login_status
    # ap @response.body
    # assert_response 200
  end

  # valid cookies
  # email
  test 'should create session, cookies and new remember_login' do

  end


  # --- fb_register ---

  # fb_access_token may need to change for every test
  test 'template test' do
    post :fb_register, {
      user: {
        fb_access_token: "CAAIPtruQfZBgBAHQWdYsTlPm0WFGwJJx3HLkWvIiR8sls985rIPk44J4j51PCJppfkOIaD8M6ivSyXaFLZBKlA7dgB45HLQ76E1tW6BRA6qWcom0HBGZA90K2HZBzuL9bu2ZBjGYxHu1nwvI3P4ItjTuf2IAZAY3Pj8lv4nndlHoAFzyXqdIiqAdA65SIfjYnRFx8am9G9sgZDZD",
        fb_user_id: "720697944",
        name: "Daiwei Lu",
        email: "daiweilu@email.com"
      }
    }
    assert_template :fb_register
    json = MultiJson.load(@response.body)
    refute_nil json["code"]
    refute_nil json["user"]
  end

  # invalid fb_access_token
  test 'should response 406' do
    post :fb_register, {
      user: {
        fb_access_token: "what is that",
        fb_user_id: "720697944",
        name: "Daiwei Lu",
        email: "daiweilu@email.com"
      }
    }
    assert_response 406
  end

end
