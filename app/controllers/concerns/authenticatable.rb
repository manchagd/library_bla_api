# frozen_string_literal: true

module Authenticatable
  extend ActiveSupport::Concern

  included do
    attr_reader :current_user
  end

  private

  def authenticate_request!
    token = request.headers["Authorization"]&.split&.last
    raise Errors::Auth::InvalidToken, "Missing token" unless token

    decoded_token = Warden::JWTAuth::TokenDecoder.new.call(token)
    user = User.find(decoded_token["sub"])

    raise Errors::Auth::RevokedToken if user.jti != decoded_token["jti"]

    @current_user = user
  rescue JWT::DecodeError
    raise Errors::Auth::InvalidToken, "Invalid token"
  rescue ActiveRecord::RecordNotFound
    raise Errors::Auth::Unauthorized, "User not found"
  end
end
