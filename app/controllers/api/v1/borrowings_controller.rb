# frozen_string_literal: true

module Api
  module V1
    class BorrowingsController < ApplicationController
      before_action :authenticate_request!
      after_action :verify_authorized, except: :index
      after_action :verify_policy_scoped, only: :index

      def index
        authorize Borrowing
        result = RequestEntryPoint::Borrowings::ListBorrowings.call(scope: policy_scope(Borrowing))
        pagy, records = pagy(result.borrowings)
        render_response(data: BorrowingBlueprint.render_as_hash(records), meta: pagy_metadata(pagy))
      end

      def show
        authorize borrowing
        render_response(data: BorrowingBlueprint.render_as_hash(borrowing))
      end

      def create
        authorize Borrowing
        result = RequestEntryPoint::Borrowings::CreateBorrowing.call(
          user: current_user,
          book_id: borrowing_params[:book_id]
        )
        render_response(data: BorrowingBlueprint.render_as_hash(result.borrowing), status: :created)
      end

      def return_borrowing
        authorize borrowing, :return?
        result = RequestEntryPoint::Borrowings::ReturnBorrowing.call(borrowing: borrowing)
        render_response(data: BorrowingBlueprint.render_as_hash(result.borrowing))
      end

      private

      def borrowing
        @borrowing ||= Borrowing.find(params[:id])
      end

      def borrowing_params
        params.require(:borrowing).permit(:book_id)
      end
    end
  end
end
