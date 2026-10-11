FactoryBot.define do
  factory :event do
    name {"ROR Workshop"}
    description {"ROR Workshop description"}
    location {"Lahore Expo"}
    date { Date.current + 7.days }
    association :user
    association :category
  end
end