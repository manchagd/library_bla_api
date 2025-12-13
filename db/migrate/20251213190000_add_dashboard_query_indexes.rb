# frozen_string_literal: true

class AddDashboardQueryIndexes < ActiveRecord::Migration[7.2]
  def change
    # Index for "due today" and "overdue" queries on active borrowings
    # Supports: Borrowing.active.where(due_at: range) and Borrowing.active.where('due_at < ?', time)
    # Columns: due_at (for range/comparison filtering)
    # Partial: status = 0 (only active borrowings)
    add_index :borrowings, :due_at,
              where: 'status = 0',
              name: 'index_active_borrowings_on_due_at'

    # Index for grouping overdue borrowings by user
    # Supports: Borrowing.active.where('due_at < ?', time).group(:user_id).count
    # Columns: due_at, user_id (filter then group)
    # Partial: status = 0 (only active borrowings)
    add_index :borrowings, %i[due_at user_id],
              where: 'status = 0',
              name: 'index_active_borrowings_on_due_at_and_user'
  end
end
