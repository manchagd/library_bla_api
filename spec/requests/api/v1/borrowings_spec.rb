# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/borrowings', type: :request do
  let(:librarian) { create(:user, :librarian) }
  let(:member) { create(:user, role: :member) }
  let(:other_member) { create(:user, role: :member) }

  def generate_jwt(user)
    Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
  end

  path '/api/v1/borrowings' do
    get 'List borrowings' do
      tags 'Borrowings'
      produces 'application/json'
      security [Bearer: []]
      description 'Librarians see all borrowings. Members see only their own.'

      context 'when librarian' do
        response '200', 'borrowings found' do
          let(:Authorization) { "Bearer #{generate_jwt(librarian)}" }

          before do
            create(:borrowing, user: member)
            create(:borrowing, user: other_member)
          end

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['data'].size).to eq(2)
          end
        end
      end

      context 'when member' do
        response '200', 'member sees only own borrowings' do
          let(:Authorization) { "Bearer #{generate_jwt(member)}" }

          before do
            create(:borrowing, user: member)
            create(:borrowing, user: other_member)
          end

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['data'].size).to eq(1)
            expect(data['data'].first['user_id']).to eq(member.id)
          end
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid' }

        run_test!
      end
    end

    post 'Create borrowing' do
      tags 'Borrowings'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]
      description 'Members can borrow available books. Cannot borrow same book twice concurrently.'
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

      let(:book) { create(:book, total_copies: 5) }
      let(:borrowing) { { borrowing: { book_id: book.id } } }

      response '201', 'borrowing created' do
        let(:Authorization) { "Bearer #{generate_jwt(member)}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']['status']).to eq('active')
          expect(data['data']['user_id']).to eq(member.id)
          expect(data['data']['book_id']).to eq(book.id)
        end
      end

      response '403', 'forbidden for librarian' do
        let(:Authorization) { "Bearer #{generate_jwt(librarian)}" }

        run_test!
      end

      context 'when book not available' do
        let(:book) { create(:book, total_copies: 0) }

        response '422', 'book not available' do
          let(:Authorization) { "Bearer #{generate_jwt(member)}" }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['errors'].first['code']).to eq('book_not_available')
          end
        end
      end

      context 'when already borrowed' do
        response '409', 'already borrowed' do
          let(:Authorization) { "Bearer #{generate_jwt(member)}" }

          before { create(:borrowing, user: member, book: book) }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['errors'].first['code']).to eq('already_borrowed')
          end
        end
      end
    end
  end

  path '/api/v1/borrowings/{id}' do
    parameter name: :id, in: :path, type: :integer

    get 'Show borrowing' do
      tags 'Borrowings'
      produces 'application/json'
      security [Bearer: []]
      description 'Librarians can see any borrowing. Members can only see their own.'

      response '200', 'borrowing found (librarian)' do
        let(:Authorization) { "Bearer #{generate_jwt(librarian)}" }
        let(:id) { create(:borrowing, user: member).id }

        run_test!
      end

      response '200', 'borrowing found (own)' do
        let(:Authorization) { "Bearer #{generate_jwt(member)}" }
        let(:id) { create(:borrowing, user: member).id }

        run_test!
      end

      response '403', 'forbidden (other user borrowing)' do
        let(:Authorization) { "Bearer #{generate_jwt(member)}" }
        let(:id) { create(:borrowing, user: other_member).id }

        run_test!
      end

      response '404', 'borrowing not found' do
        let(:Authorization) { "Bearer #{generate_jwt(librarian)}" }
        let(:id) { 0 }

        run_test!
      end
    end
  end

  path '/api/v1/borrowings/{id}/return' do
    parameter name: :id, in: :path, type: :integer

    post 'Return borrowing' do
      tags 'Borrowings'
      produces 'application/json'
      security [Bearer: []]
      description 'Only librarians can mark a borrowing as returned.'

      response '200', 'borrowing returned' do
        let(:Authorization) { "Bearer #{generate_jwt(librarian)}" }
        let(:id) { create(:borrowing, user: member).id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']['status']).to eq('returned')
          expect(data['data']['returned_at']).not_to be_nil
        end
      end

      response '403', 'forbidden for member' do
        let(:Authorization) { "Bearer #{generate_jwt(member)}" }
        let(:id) { create(:borrowing, user: member).id }

        run_test!
      end

      response '422', 'borrowing not active' do
        let(:Authorization) { "Bearer #{generate_jwt(librarian)}" }
        let(:id) { create(:borrowing, :returned, user: member).id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors'].first['code']).to eq('borrowing_not_active')
        end
      end

      response '404', 'borrowing not found' do
        let(:Authorization) { "Bearer #{generate_jwt(librarian)}" }
        let(:id) { 0 }

        run_test!
      end
    end
  end
end
