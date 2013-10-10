# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do

    factory :validUser do
      id 1
      login 'admin'
      password 'password'
      password_confirmation 'password'
      email 'admin@host.com'
      active true
    end

    factory :invalidUser do
      login 'admin'
      password 'invalid_password'
      password_confirmation 'invalid_password'
      email 'admin@host.com'
      active true
    end

    factory :invalidUserShortPassword do
      login 'a'
      password '1'
      password_confirmation '1'
      email 'a@host.com'
      active true
    end

    factory :validDevUser do
      id 5
      login 'dev'
      password 'devpass'
      password_confirmation 'devpass'
      email 'dev@host.com'
      active true
    end

    factory :inactiveUser do
      id 6
      login 'dev'
      password 'devpass'
      password_confirmation 'devpass'
      email 'dev@host.com'
      active false
    end

  end
end
