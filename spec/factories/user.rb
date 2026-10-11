FactoryBot.define do
  factory :user do
    name { "Demo user1" }
    email { "test123@example.com" }
    password { "password123" }
    role { "organizer" }
  end
end