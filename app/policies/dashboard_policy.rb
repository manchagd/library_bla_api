# frozen_string_literal: true

class DashboardPolicy < ApplicationPolicy
  def show?
    user.present?
  end

  delegate :librarian?, to: :user

  delegate :member?, to: :user
end
