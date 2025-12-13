# frozen_string_literal: true

class BorrowingBlueprint < Blueprinter::Base
  identifier :id

  field :data_type do
    'borrowing'
  end

  fields :status, :borrowed_at, :due_at, :returned_at, :user_id, :book_id, :created_at, :updated_at

  association :book, blueprint: BookBlueprint
end
