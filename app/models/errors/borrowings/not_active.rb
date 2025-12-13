# frozen_string_literal: true

module Errors
  module Borrowings
    class NotActive < Errors::AppErrors::ApplicationError
      def initialize(msg = 'Borrowing is not active')
        super(msg, status: :unprocessable_entity, code: :borrowing_not_active)
      end
    end
  end
end
