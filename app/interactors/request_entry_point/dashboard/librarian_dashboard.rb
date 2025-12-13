# frozen_string_literal: true

module RequestEntryPoint
  module Dashboard
    class LibrarianDashboard < BaseService
      def call
        context.dashboard = {
          total_books: total_books,
          total_borrowed_books: total_borrowed_books,
          books_due_today: books_due_today,
          members_with_overdue_books: members_with_overdue_books
        }
      end

      private

      def total_books
        Book.count
      end

      def total_borrowed_books
        Borrowing.active.count
      end

      def books_due_today
        Borrowing.active.where(due_at: today_range).count
      end

      def today_range
        Time.current.all_day
      end

      def members_with_overdue_books
        overdue_data.map do |user_id, borrowings|
          user = users_cache[user_id]
          {
            user_id: user_id,
            email: user&.email,
            overdue_count: borrowings.size,
            overdue_books: borrowings.map { |b| b.book.title }
          }
        end
      end

      def overdue_data
        @overdue_data ||= Borrowing
                          .active
                          .where(due_at: ...Time.current)
                          .includes(:book, :user)
                          .group_by(&:user_id)
      end

      def users_cache
        @users_cache ||= User.where(id: overdue_data.keys).index_by(&:id)
      end
    end
  end
end
