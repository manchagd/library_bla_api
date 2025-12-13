# frozen_string_literal: true

class BorrowingPolicy < ApplicationPolicy
  def index?
    user.librarian? || user.member? # Members can see their own, filtered by scope
  end

  def show?
    user.librarian? || record.user_id == user.id
  end

  def create?
    user.member?
  end

  def update?
    user.librarian?
  end

  # Custom action
  def return_book?
    user.librarian? || (user.member? && record.user_id == user.id)
  end

  class Scope < Scope
    def resolve
      if user.librarian?
        scope.all
      else
        scope.where(user: user)
      end
    end
  end
end
