FactoryBot.define do
  factory :notification do
    user { nil }
    event { nil }
    action { "MyString" }
    read_at { "2026-11-10 15:10:28" }
    actor_id { "" }
  end
end
