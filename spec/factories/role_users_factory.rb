# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :role_user do
    factory :userHasValidRole do
      user_id 1
      role_id 1
    end

    factory :userHasDevRole do
      user_id 5
      role_id 2
    end
  end
end
