# frozen_string_literal: true

module Errors
  module Borrowings
    class AlreadyBorrowed < Errors::AppErrors::ApplicationError
      def initialize(msg = 'You already have an active borrowing for this book')
        super(msg, status: :conflict, code: :already_borrowed)
      end
    end
  end
end
