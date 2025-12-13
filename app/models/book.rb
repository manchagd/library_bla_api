# frozen_string_literal: true

class Book < ApplicationRecord
  has_many :borrowings, dependent: :restrict_with_error

  validates :title, :author, :genre, :isbn, :total_copies, presence: true
  validates :isbn, uniqueness: { case_sensitive: false }
  validates :total_copies, numericality: { greater_than_or_equal_to: 0, only_integer: true }
end
