# frozen_string_literal: true

module Errors
  module Books
    class NotFound < Errors::AppErrors::ApplicationError
      def initialize(msg = 'Book not found')
        super(msg, status: :not_found, code: :book_not_found)
      end
    end
  end
end
