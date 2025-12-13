# frozen_string_literal: true

module Dashboard
  class MemberDashboardBlueprint < Blueprinter::Base
    field :data_type do
      'member_dashboard'
    end

    field :active_borrowings
    field :overdue_borrowings
    field :overdue_count
  end
end
