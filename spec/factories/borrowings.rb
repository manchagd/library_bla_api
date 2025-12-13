# frozen_string_literal: true

FactoryBot.define do
  factory :borrowing do
    association :user
    association :book
    borrowed_at { Time.current }
    due_at { 2.weeks.from_now }
    status { :active }

    trait :returned do
      status { :returned }
      returned_at { 1.week.from_now }
    end
  end
end
