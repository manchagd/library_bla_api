# frozen_string_literal: true

class BookBlueprint < Blueprinter::Base
  identifier :id

  field :data_type do
    'book'
  end

  fields :title, :author, :genre, :isbn, :total_copies, :created_at, :updated_at
end
