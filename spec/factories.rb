FactoryGirl.define do
  sequence(:random_string) {|n| (0...50).map{ ('a'..'z').to_a[rand(26)] }.join }

  factory :user do
    name  'Daiwei Lu'
    email 'daiweilu@email.com'
    # profile_picture

    password_salt '2972bf1fec73c591c19f7734504c09fb05a7021f'
    password_hash '9a3b7bb6a6470a16bda3c57edb3653dd9266baa7' # pw: 12345678

    # fb_access_token
    # fb_user_id
  end

  factory :user_with_facebook_login, class: User do
    name 'Daiwei Lu'
    email 'daiweilu123@gmail.com'

    fb_access_token 'CAAIPtruQfZBgBAAADjJZC37iOAcaBnWQ3zluVqgExemu0DqHZAlBlmPNB5RlXZCfFZCshoHpmNsZAo9I3D0my9DexZBX2YQGNPFIdexy9SxZBe30RcN4nuVnU7YoNZB3xUNylxPigweRGjAOUEF3g2eQo8gHE1GQtDlwh3simYITUYyN4EBtz4J972JZCQnI6gp9Yq2hkyhw2i8QZDZD'
    fb_user_id '720697944'
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
