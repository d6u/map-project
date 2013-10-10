require 'spec_helper'

describe Api::AuthController do
  describe 'GET fb_login' do
    it 'should return token code and user data' do
      user = FactoryGirl.create(:user_with_facebook_login)
      post :fb_login, {user: {
        fb_access_token: user.fb_access_token,
        fb_user_id:      user.fb_user_id,
        name:            user.name,
        email:           user.email
      }}
      expect(response.status).to eq(200)
      expect(session[:user_id]).not_to be_nil
      rl = RememberLogin.find_by_remember_token(response.cookies['user_token'])
      expect(response.cookies['user_token']).to eq(rl.remember_token)
      expect(rl.login_type).to eq(1)
      expect(response.cookies['user_id']).to eq(session[:user_id].to_s)
    end

    it 'should return 406 because user not exist' do
      user = FactoryGirl.build(:user_with_facebook_login)
      post :fb_login, {user: {
        fb_access_token: 1234567890,
        fb_user_id:      user.fb_user_id,
        name:            user.name,
        email:           user.email
      }}
      expect(response.status).to eq(406)
    end

    it 'should return 406 because user not exist' do
      user = FactoryGirl.create(:user_with_facebook_login)
      post :fb_login, {user: {
        fb_access_token: 1234567890,
        fb_user_id:      user.fb_user_id,
        name:            user.name,
        email:           user.email
      }}
      expect(response.status).to eq(406)
    end
  end
end
