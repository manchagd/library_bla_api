# frozen_string_literal: true

FactoryBot.define do
  factory :borrowing do
    association :user
    association :book
    borrowed_at { Time.current }
    due_at { borrowed_at + 2.weeks }
    status { :active }

    trait :returned do
      status { :returned }
      returned_at { 1.week.from_now }
    end

    trait :due_today do
      borrowed_at { 2.weeks.ago }
      due_at { borrowed_at + 2.weeks }
    end

    trait :overdue do
      transient do
        days_overdue { 3 }
      end

      borrowed_at { (2.weeks + days_overdue.days).ago }
      due_at { borrowed_at + 2.weeks }
    end
  end
end
