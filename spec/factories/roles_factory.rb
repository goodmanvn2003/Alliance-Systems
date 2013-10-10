# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :role do
    factory :adminRole do
      id 1
      name 'admin'
    end

    factory :developerRole do
      id 2
      name 'developer'
    end
  end
end
