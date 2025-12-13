# frozen_string_literal: true

module Errors
  module Borrowings
    class BookNotAvailable < Errors::AppErrors::ApplicationError
      def initialize(msg = 'Book is not available for borrowing')
        super(msg, status: :unprocessable_entity, code: :book_not_available)
      end
    end
  end
end
