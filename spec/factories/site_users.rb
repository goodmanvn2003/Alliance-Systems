# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :site_user do
    users_id 1
    sites_id 1
    roles_id 1
    is_owner false
  end
end
