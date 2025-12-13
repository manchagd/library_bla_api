# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/books', type: :request do
  let(:librarian) { create(:user, role: :librarian) }
  let(:member) { create(:user, role: :member) }

  def generate_jwt(user)
    Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
  end

  path '/api/v1/books' do
    get 'List books' do
      tags 'Books'
      produces 'application/json'
      security [Bearer: []]
      parameter name: :query, in: :query, type: :string, required: false, description: 'Search by title/author/genre'

      response '200', 'books found' do
        let(:Authorization) { "Bearer #{generate_jwt(librarian)}" }

        before { create_list(:book, 3) }

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
        let(:Authorization) { "Bearer #{generate_jwt(librarian)}" }
        let(:book) { { book: attributes_for(:book) } }

        run_test!
      end

      response '403', 'forbidden for member' do
        let(:Authorization) { "Bearer #{generate_jwt(member)}" }
        let(:book) { { book: attributes_for(:book) } }

        run_test!
      end
    end
  end

  path '/api/v1/books/{id}' do
    parameter name: :id, in: :path, type: :integer

    get 'Show book' do
      tags 'Books'
      produces 'application/json'
      security [Bearer: []]

      response '200', 'book found' do
        let(:Authorization) { "Bearer #{generate_jwt(librarian)}" }
        let(:id) { create(:book).id }

        run_test!
      end

      response '404', 'book not found' do
        let(:Authorization) { "Bearer #{generate_jwt(librarian)}" }
        let(:id) { 0 }

        run_test!
      end
    end

    patch 'Update book' do
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
              total_copies: { type: :integer }
            }
          }
        }
      }

      response '200', 'book updated' do
        let(:Authorization) { "Bearer #{generate_jwt(librarian)}" }
        let(:id) { create(:book).id }
        let(:book) { { book: { title: 'Updated Title' } } }

        run_test!
      end
    end

    delete 'Delete book' do
      tags 'Books'
      security [Bearer: []]

      response '204', 'book deleted' do
        let(:Authorization) { "Bearer #{generate_jwt(librarian)}" }
        let(:id) { create(:book).id }

        run_test!
      end
    end
  end
end
