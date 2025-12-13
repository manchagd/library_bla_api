# frozen_string_literal: true

class Borrowing < ApplicationRecord
  belongs_to :user
  belongs_to :book

  enum :status, { active: 0, returned: 1 }, default: :active

  validates :borrowed_at, :due_at, presence: true
  validate :due_date_must_be_two_weeks_after_borrowed_date

  before_validation :set_due_date, on: :create

  private

  def set_due_date
    self.borrowed_at ||= Time.current
    self.due_at ||= borrowed_at + 2.weeks if borrowed_at.present?
  end

  def due_date_must_be_two_weeks_after_borrowed_date
    return unless borrowed_at.present? && due_at.present?

    # Using to_i to compare timestamps without microsecond issues, or just exact comparison
    # The requirement is "exactly 2 weeks".
    return if due_at == borrowed_at + 2.weeks

    errors.add(:due_at, "must be exactly 2 weeks after borrowed_at")
  end
end
