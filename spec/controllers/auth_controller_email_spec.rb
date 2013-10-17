require 'spec_helper'

describe Api::AuthController do
  describe 'GET email_register' do
    it 'should issue session, remember user and return user data' do
      user = FactoryGirl.build(:user)

      post :email_register, {
        password:              12345678,
        password_confirmation: 12345678,
        name:                  user.name,
        email:                 user.email
      }

      expect(response.status).to eq(200)
      expect(session[:user_id]).to eq(User.find_by_email(user.email).id)

      rl = User.find_by_email(user.email).remember_logins[0]
      expect(response.cookies['user_id']).to    eq(rl.user_id.to_s)
      expect(response.cookies['user_token']).to eq(rl.remember_token.to_s)
    end


    it 'should return error message because password does not match' do
      user = FactoryGirl.build(:user)

      post :email_register, {
        password:              12345678,
        password_confirmation: 87654321,
        name:                  user.name,
        email:                 user.email
      }

      expect(response.status).to eq(406)
    end
  end


  describe 'GET email_login' do
    it 'should issue session, not cookies' do
      user = FactoryGirl.create(:user)

      post :email_login, {
        password: 12345678,
        email:    user.email
      }

      expect(session[:user_id]).to eq(user.id)
      expect(response.cookies['user_id']).to    be_nil
      expect(response.cookies['user_token']).to be_nil
    end


    it 'should issue both session and cookies' do
      user = FactoryGirl.create(:user)

      post :email_login, {
        password:    12345678,
        email:       user.email,
        remember_me: true
      }

      expect(session[:user_id]).to eq(user.id)
      expect(response.cookies['user_id']).to    eq(user.id.to_s)
      expect(response.cookies['user_token']).to eq(User.find(user.id).remember_logins[0].remember_token)
    end


    it 'should return 406' do
      user = FactoryGirl.create(:user)

      post :email_login, {
        password:    123456789,
        email:       user.email,
        remember_me: true
      }

      expect(response.status).to eq(406)
    end
  end
end
