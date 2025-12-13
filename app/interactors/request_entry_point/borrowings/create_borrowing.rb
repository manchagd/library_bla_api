# frozen_string_literal: true

module RequestEntryPoint
  module Borrowings
    class CreateBorrowing < BaseService
      def call
        ActiveRecord::Base.transaction do
          validate_borrowing!
          context.borrowing = create_borrowing!
        end
      end

      private

      def book
        @book ||= Book.lock.find(context.book_id)
      end

      def user
        context.user
      end

      def validate_borrowing!
        raise ::Errors::Borrowings::BookNotAvailable unless book.available?
        raise ::Errors::Borrowings::AlreadyBorrowed if active_borrowing_exists?
      end

      def active_borrowing_exists?
        Borrowing.active.exists?(user_id: user.id, book_id: book.id)
      end

      def create_borrowing!
        Borrowing.create!(user: user, book: book)
      end
    end
  end
end
