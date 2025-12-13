# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Pagy::Backend
  include ErrorHandling
  include ResponseHandling
  include Authenticatable
  include Pundit::Authorization
end
