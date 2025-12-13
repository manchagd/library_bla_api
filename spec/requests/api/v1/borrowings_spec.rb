require 'swagger_helper'

RSpec.describe 'api/v1/borrowings', type: :request do
  path '/api/v1/borrowings' do
    get 'List borrowings' do
      tags 'Borrowings'
      produces 'application/json'
      security [Bearer: []]

      response '200', 'borrowings list' do
        let(:user) { FactoryBot.create(:user) }
        let(:token) { Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first }
        let(:Authorization) { "Bearer #{token}" }
        run_test!
      end
    end

    post 'Create borrowing' do
      tags 'Borrowings'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]
      parameter name: :borrowing, in: :body, schema: {
        type: :object,
        properties: {
          borrowing: {
            type: :object,
            properties: {
              book_id: { type: :integer }
            },
            required: %w[book_id]
          }
        }
      }

      response '201', 'borrowing created' do
        let(:user) { FactoryBot.create(:user) }
        let(:token) { Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first }
        let(:Authorization) { "Bearer #{token}" }
        let(:book) { FactoryBot.create(:book) }
        let(:borrowing) { { borrowing: { book_id: book.id } } }
        run_test!
      end
    end
  end

  path '/api/v1/borrowings/{id}/return_book' do
    patch 'Return book' do
      tags 'Borrowings'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]
      parameter name: :id, in: :path, type: :string

      response '200', 'book returned' do
        let(:user) { FactoryBot.create(:user) }
        let(:book) { FactoryBot.create(:book) }
        let(:borrowing_record) { FactoryBot.create(:borrowing, user: user, book: book) }
        let(:id) { borrowing_record.id }
        let(:token) { Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first }
        let(:Authorization) { "Bearer #{token}" }
        run_test!
      end
    end
  end
end
