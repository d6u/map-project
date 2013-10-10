# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :chat_history do
    user nil
    project nil
    type 1
    content ""
  end
end
