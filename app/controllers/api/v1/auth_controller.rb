# frozen_string_literal: true

module Api
  module V1
    class AuthController < ApplicationController
      before_action :authenticate_request!, only: [:logout]

      def login
        result = RequestEntryPoint::Auth::Login.call(
          email: params[:email],
          password: params[:password]
        )

        if result.success?
          data = { token: result.token, user: UserBlueprint.render_as_hash(result.user) }
          render_response(data: data)
        else
          render_error(message: result.message, status: :unauthorized, code: :unauthorized)
        end
      end

      def logout
        result = RequestEntryPoint::Auth::Logout.call(user: current_user)

        if result.success?
          render_response(data: { message: 'Logged out successfully' })
        else
          render_error(message: result.message, status: :unprocessable_entity, code: :unprocessable_entity)
        end
      end
    end
  end
end
