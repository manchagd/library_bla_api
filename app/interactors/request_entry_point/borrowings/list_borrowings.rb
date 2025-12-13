# frozen_string_literal: true

module RequestEntryPoint
  module Borrowings
    class ListBorrowings < BaseService
      def call
        context.borrowings = context.scope
      end
    end
  end
end
