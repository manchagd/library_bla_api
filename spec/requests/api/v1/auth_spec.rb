# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/auth', type: :request do
  def generate_jwt(user)
    Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
  end

  path '/api/v1/auth/login' do
    post 'Login' do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: %w[email password]
      }

      response '200', 'logged in' do
        let(:user) { create(:user, password: 'password') }
        let(:credentials) { { email: user.email, password: 'password' } }

        run_test!
      end

      response '401', 'invalid credentials' do
        let(:credentials) { { email: 'test@example.com', password: 'wrong' } }

        run_test!
      end
    end
  end

  path '/api/v1/auth/logout' do
    delete 'Logout' do
      tags 'Auth'
      security [Bearer: []]

      response '200', 'logged out' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{generate_jwt(user)}" }

        run_test!
      end

      response '401', 'missing token' do
        let(:Authorization) { nil }

        run_test!
      end
    end
  end
end
