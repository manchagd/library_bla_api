require 'swagger_helper'

RSpec.describe 'api/v1/auth', type: :request do
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
        required: [ 'email', 'password' ]
      }

      response '200', 'logged in' do
        let(:user) { FactoryBot.create(:user, password: 'password') }
        let(:credentials) { { email: user.email, password: 'password' } }
        run_test!
      end

      response '401', 'invalid credentials' do
        let(:credentials) { { email: 'wrong', password: 'wrong' } }
        run_test!
      end
    end
  end

  path '/api/v1/auth/logout' do
    delete 'Logout' do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      response '200', 'logged out' do
        let(:user) { FactoryBot.create(:user) }
        let(:token) { Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first }
        let(:Authorization) { "Bearer #{token}" }
        run_test!
      end

      response '401', 'missing token' do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end
end
