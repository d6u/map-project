require 'spec_helper'

describe 'AuthControllerFbRegisters' do
  describe 'GET /api/auth/fb_register' do
    it 'should return code and user data' do
      user = FactoryGirl.build(:user_with_facebook_login)
      post '/api/auth/fb_register', {user: {
        fb_access_token: user.fb_access_token,
        fb_user_id:      user.fb_user_id,
        name:            user.name,
        email:           user.email
      }}
      data = MultiJson.load(response.body)
      expect(data['code']).not_to be_nil

      returned_user = User.find(session[:user_id])
      expect(data['user']).not_to eq({
        id:    returned_user.id,
        name:  returned_user.name,
        email: returned_user.email,
        profile_picture:  returned_user.profile_picture
      })
    end
  end
end
