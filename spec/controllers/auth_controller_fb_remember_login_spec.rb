require 'spec_helper'

describe Api::AuthController do
  describe 'GET fb_remember_login' do
    it 'should return token code and user data' do
      remember_login = FactoryGirl.create(:remember_login_fb)
      user           = remember_login.user
      request.cookies['user_token'] = remember_login.remember_token
      request.cookies['user_id']    = remember_login.user_id

      post :fb_remember_login, {user: {
        fb_access_token: user.fb_access_token,
        fb_user_id:      user.fb_user_id
      }}

      expect(response.status).to eq(200)

      expect(session[:user_id]).not_to be_nil

      rl = RememberLogin.find_by_remember_token(response.cookies['user_token'])
      expect(response.cookies['user_token']).to eq(rl.remember_token)
      expect(rl.login_type).to eq(1)
      expect(rl.user_id).to eq(user.id)

      expect(RememberLogin.find_by_id(remember_login.id)).to be_nil

      expect(response.cookies['user_id']).to eq(session[:user_id].to_s)
    end


    it 'should return 406 because remember_login does not exist' do
      remember_login = FactoryGirl.create(:remember_login_fb)
      user           = remember_login.user
      request.cookies['user_token'] = '1234567890'
      request.cookies['user_id']    = remember_login.user_id

      post :fb_remember_login, {user: {
        fb_access_token: user.fb_access_token,
        fb_user_id:      user.fb_user_id
      }}

      expect(response.status).to eq(406)
    end


    it 'should return 406 because fb_user_id not match' do
      remember_login = FactoryGirl.create(:remember_login_fb)
      user           = remember_login.user
      request.cookies['user_token'] = remember_login.remember_token
      request.cookies['user_id']    = remember_login.user_id

      post :fb_remember_login, {user: {
        fb_access_token: user.fb_access_token,
        fb_user_id:      '1234567890'
      }}

      expect(response.status).to eq(406)
    end
  end
end
