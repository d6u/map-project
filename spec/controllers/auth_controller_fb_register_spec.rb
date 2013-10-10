require 'spec_helper'

describe Api::AuthController do
  describe 'GET fb_register' do
    it 'should return token code and user data' do
      user = FactoryGirl.build(:user_with_facebook_login)
      post :fb_register, {user: {
        fb_access_token: user.fb_access_token,
        fb_user_id:      user.fb_user_id,
        name:            user.name,
        email:           user.email
      }}
      expect(response.status).to eq(200)
      expect(session[:user_id]).not_to be_nil
      expect(response.cookies['user_token']).to eq(RememberLogin.find_by_remember_token(response.cookies['user_token']).remember_token)
      expect(response.cookies['user_id']).to eq(session[:user_id].to_s)
    end

    it 'should return 406' do
      user = FactoryGirl.build(:user_with_facebook_login)
      post :fb_register, {user: {
        fb_access_token: 1234567890,
        fb_user_id:      user.fb_user_id,
        name:            user.name,
        email:           user.email
      }}
      expect(response.status).to eq(406)
    end
  end
end
