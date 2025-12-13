# frozen_string_literal: true

module RequestEntryPoint
  module Borrowings
    class ReturnBorrowing < BaseService
      def call
        borrowing = context.borrowing

        raise ::Errors::Borrowings::NotActive unless borrowing.active?

        borrowing.update!(
          status: :returned,
          returned_at: Time.current
        )

        context.borrowing = borrowing
      end
    end
  end
end
