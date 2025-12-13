# frozen_string_literal: true

module RequestEntryPoint
  module Books
    class DeleteBook < BaseService
      def call
        book = Book.find_by(id: context.book_id)
        raise Errors::Books::NotFound unless book

        book.destroy!
        context.book = book
      end
    end
  end
end
