# frozen_string_literal: true

module RequestEntryPoint
  module Books
    class UpdateBook < BaseService
      def call
        book = Book.find_by(id: context.book_id)
        raise Errors::Books::NotFound unless book

        if book.update(context.book_params)
          context.book = book
        else
          context.fail!(message: book.errors.full_messages.join(', '))
        end
      end
    end
  end
end
