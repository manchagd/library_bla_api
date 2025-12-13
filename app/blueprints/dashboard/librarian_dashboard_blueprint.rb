# frozen_string_literal: true

module Dashboard
  class LibrarianDashboardBlueprint < Blueprinter::Base
    field :data_type do
      'librarian_dashboard'
    end

    field :total_books
    field :total_borrowed_books
    field :books_due_today
    field :members_with_overdue_books
  end
end
