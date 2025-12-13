# frozen_string_literal: true

class AddUniqueActiveBorrowingIndex < ActiveRecord::Migration[7.2]
  def change
    add_index :borrowings, %i[user_id book_id],
              unique: true,
              where: 'status = 0',
              name: 'index_unique_active_borrowing'
  end
end
