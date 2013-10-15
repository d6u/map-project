# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notice do
    sender nil
    receiver nil
    project nil
    type 1
    content ""
  end
end
