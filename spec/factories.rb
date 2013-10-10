FactoryGirl.define do
  sequence(:random_string) {|n| (0...50).map{ ('a'..'z').to_a[rand(26)] }.join }

  factory :user do
    id    123
    name  'Daiwei Lu'
    email 'daiweilu@email.com'
    # profile_picture

    password_salt '2972bf1fec73c591c19f7734504c09fb05a7021f'
    password_hash '9a3b7bb6a6470a16bda3c57edb3653dd9266baa7' # pw: 12345678

    # fb_access_token
    # fb_user_id
  end

  factory :remember_login_email, class: RememberLogin do
    remember_token { generate(:random_string) }
    login_type 0
    user
  end

  factory :remember_login_fb, class: RememberLogin do
    remember_token { generate(:random_string) }
    login_type 1
    user
  end
end
