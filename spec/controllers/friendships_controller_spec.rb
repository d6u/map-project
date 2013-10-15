require 'spec_helper'


describe Api::FriendshipsController do

  describe "POST /api/friendships" do
    it "create friendship request and notice" do
      user1 = FactoryGirl.create :user
      user2 = FactoryGirl.create :user_with_facebook_login

      post :create, {friendship: {friend_id: user2.id}}, {user_id: user1.id}
      expect(response.status).to eq(200)
    end
  end

end
