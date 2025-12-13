# frozen_string_literal: true

module RequestEntryPoint
  module Dashboard
    class MemberDashboard < BaseService
      def call
        context.dashboard = {
          active_borrowings: active_borrowings_data,
          overdue_borrowings: overdue_borrowings_data,
          overdue_count: overdue_count
        }
      end

      private

      def user
        context.user
      end

      def active_borrowings
        @active_borrowings ||= Borrowing
                               .active
                               .where(user: user)
                               .includes(:book)
                               .order(due_at: :asc)
      end

      def active_borrowings_data
        active_borrowings.map do |borrowing|
          {
            id: borrowing.id,
            book_id: borrowing.book_id,
            book_title: borrowing.book.title,
            borrowed_at: borrowing.borrowed_at,
            due_at: borrowing.due_at,
            overdue: borrowing.due_at < Time.current
          }
        end
      end

      def overdue_borrowings
        @overdue_borrowings ||= active_borrowings.select { |b| b.due_at < Time.current }
      end

      def overdue_borrowings_data
        overdue_borrowings.map do |borrowing|
          {
            id: borrowing.id,
            book_id: borrowing.book_id,
            book_title: borrowing.book.title,
            due_at: borrowing.due_at,
            days_overdue: ((Time.current - borrowing.due_at) / 1.day).to_i
          }
        end
      end

      def overdue_count
        overdue_borrowings.size
      end
    end
  end
end
