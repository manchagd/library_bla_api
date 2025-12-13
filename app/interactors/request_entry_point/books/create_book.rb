# frozen_string_literal: true

module RequestEntryPoint
  module Books
    class CreateBook < BaseService
      def call
        book = Book.new(context.book_params)

        if book.save
          context.book = book
        else
          context.fail!(message: book.errors.full_messages.join(', '))
        end
      end
    end
  end
end
