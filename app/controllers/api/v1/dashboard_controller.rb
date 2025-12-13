# frozen_string_literal: true

module Api
  module V1
    class DashboardController < ApplicationController
      before_action :authenticate_request!
      after_action :verify_authorized

      def show
        authorize :dashboard
        result = dashboard_service.call(user: current_user)
        render_response(data: dashboard_blueprint.render_as_hash(result.dashboard))
      end

      private

      def dashboard_service
        current_user.librarian? ? librarian_service : member_service
      end

      def dashboard_blueprint
        current_user.librarian? ? librarian_blueprint : member_blueprint
      end

      def librarian_service
        RequestEntryPoint::Dashboard::LibrarianDashboard
      end

      def member_service
        RequestEntryPoint::Dashboard::MemberDashboard
      end

      def librarian_blueprint
        Dashboard::LibrarianDashboardBlueprint
      end

      def member_blueprint
        Dashboard::MemberDashboardBlueprint
      end
    end
  end
end
