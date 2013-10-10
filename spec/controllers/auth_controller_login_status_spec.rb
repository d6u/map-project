require 'spec_helper'

describe Api::AuthController do
  describe 'GET login_status' do
    # --- Session ---
    it 'return user data with valid session' do
      user = FactoryGirl.create :user
      get :login_status, nil, {user_id: user.id}
      expect(response.status).to eq(200)
      expect(response.body).to eq(user.to_json({only: [:id, :name, :profile_picture, :email]}))
      expect(session[:user_id]).to eq(user.id)
    end

    it 'response 404' do
      get :login_status
      expect(response.status).to eq(404)
    end

    it 'remove invalid session' do
      get :login_status, nil, {user_id: 0}
      expect(response.status).to eq(404)
      expect(session[:user_id]).to be_nil
    end

    # --- Cookies ---
    it 'return user data and issue new remember login cookies' do
      remember_login = FactoryGirl.create(:remember_login_email)
      user           = remember_login.user
      request.cookies['user_id']    = remember_login.user_id
      request.cookies['user_token'] = remember_login.remember_token
      get :login_status
      expect(response.status).to eq(200)
      expect(RememberLogin.find_by_id(remember_login.id)).to be_nil
      expect(response.cookies['user_id']).to eq(user.id.to_s)
      expect(response.cookies['user_token']).to eq(user.remember_logins[0].remember_token)
      expect(response.body).to eq(user.to_json({only: [:id, :name, :profile_picture, :email]}))
    end

    it 'return facebook type for facebook remember login' do
      remember_login = FactoryGirl.create(:remember_login_fb)
      user           = remember_login.user
      request.cookies['user_id']    = remember_login.user_id
      request.cookies['user_token'] = remember_login.remember_token
      get :login_status
      expect(response.status).to eq(200)
      expect(response.body).to eq(MultiJson.dump({remember_login: true, type: 'facebook'}))
    end

    it 'remove invalid cookies' do
      request.cookies['user_id'] = '0'
      get :login_status
      expect(response.status).to eq(404)
      expect(response.cookies['user_id']).to be_nil

      request.cookies['user_token'] = '123456'
      get :login_status
      expect(response.status).to eq(404)
      expect(response.cookies['user_token']).to be_nil

      request.cookies['user_token'] = '123456'
      request.cookies['user_id']    = '0'
      get :login_status
      expect(response.status).to eq(404)
      expect(response.cookies['user_id']).to be_nil
      expect(response.cookies['user_token']).to be_nil
    end
  end


  describe 'GET logout' do
    it 'should remove session and cookies' do
      remember_login = FactoryGirl.create(:remember_login_email)
      user           = remember_login.user
      request.cookies['user_id']    = remember_login.user_id
      request.cookies['user_token'] = remember_login.remember_token

      get :logout, nil, {user_id: user.id}

      expect(session[:user_id]).to be_nil
      expect(response.cookies['user_id']).to    be_nil
      expect(response.cookies['user_token']).to be_nil

      expect(RememberLogin.find_by_remember_token(remember_login.remember_token)).to be_nil
      expect(User.find(user.id).remember_logins.count).to eq(0)
    end
  end
end
