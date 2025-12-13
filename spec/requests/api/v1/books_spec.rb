require 'swagger_helper'

RSpec.describe 'api/v1/books', type: :request do
  path '/api/v1/books' do
    get 'List books' do
      tags 'Books'
      produces 'application/json'
      security [Bearer: []]

      response '200', 'books found' do
        let(:user) { FactoryBot.create(:user) }
        let(:token) { Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first }
        let(:Authorization) { "Bearer #{token}" }
        run_test!
      end
    end

    post 'Create book' do
      tags 'Books'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]
      parameter name: :book, in: :body, schema: {
        type: :object,
        properties: {
          book: {
            type: :object,
            properties: {
              title: { type: :string },
              author: { type: :string },
              genre: { type: :string },
              isbn: { type: :string },
              total_copies: { type: :integer }
            },
            required: %w[title author genre isbn total_copies]
          }
        }
      }

      response '201', 'book created' do
        let(:user) { FactoryBot.create(:user, :librarian) }
        let(:token) { Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first }
        let(:Authorization) { "Bearer #{token}" }
        let(:book) { { book: FactoryBot.attributes_for(:book) } }
        run_test!
      end

      response '403', 'forbidden for member' do
        let(:user) { FactoryBot.create(:user) }
        let(:token) { Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first }
        let(:Authorization) { "Bearer #{token}" }
        let(:book) { { book: FactoryBot.attributes_for(:book) } }
        run_test!
      end
    end
  end
end
