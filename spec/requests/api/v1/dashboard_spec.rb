# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/dashboard', type: :request do
  let(:librarian) { create(:user, :librarian) }
  let(:member) { create(:user, role: :member) }
  let(:other_member) { create(:user, role: :member) }

  def generate_jwt(user)
    Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
  end

  path '/api/v1/dashboard' do
    get 'Show dashboard' do
      tags 'Dashboard'
      produces 'application/json'
      security [Bearer: []]
      description 'Returns role-specific dashboard. Librarians see aggregate stats. Members see their borrowings.'

      context 'when librarian' do
        let(:book_due_today) { create(:book, total_copies: 5) }
        let(:book_overdue_member) { create(:book, total_copies: 3) }
        let(:book_overdue_other) { create(:book, total_copies: 2) }

        response '200', 'librarian dashboard' do
          let(:Authorization) { "Bearer #{generate_jwt(librarian)}" }

          before do
            create(:borrowing, :due_today, user: member, book: book_due_today)
            create(:borrowing, :overdue, user: member, book: book_overdue_member, days_overdue: 3)
            create(:borrowing, :overdue, user: other_member, book: book_overdue_other, days_overdue: 1)
          end

          run_test! do |response|
            data = JSON.parse(response.body)['data']
            expect(data['data_type']).to eq('librarian_dashboard')
            expect(data['total_books']).to eq(3)
            expect(data['total_borrowed_books']).to eq(3)
            expect(data['books_due_today']).to eq(1)
            expect(data['members_with_overdue_books'].size).to eq(2)
          end
        end
      end

      context 'when member' do
        let(:book_active) { create(:book, total_copies: 5) }
        let(:book_overdue) { create(:book, total_copies: 3) }

        response '200', 'member dashboard' do
          let(:Authorization) { "Bearer #{generate_jwt(member)}" }

          before do
            create(:borrowing, user: member, book: book_active)
            create(:borrowing, :overdue, user: member, book: book_overdue, days_overdue: 2)
          end

          run_test! do |response|
            data = JSON.parse(response.body)['data']
            expect(data['data_type']).to eq('member_dashboard')
            expect(data['active_borrowings'].size).to eq(2)
            expect(data['overdue_count']).to eq(1)
            expect(data['overdue_borrowings'].size).to eq(1)
          end
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid' }

        run_test!
      end
    end
  end
end
