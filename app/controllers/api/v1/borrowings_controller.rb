# frozen_string_literal: true

module Api
  module V1
    class BorrowingsController < ApplicationController
      before_action :authenticate_request!
      after_action :verify_authorized, except: :index
      after_action :verify_policy_scoped, only: :index

      def index
        @borrowings = policy_scope(Borrowing)
        authorize Borrowing
        pagy, records = pagy(@borrowings)
        render_response(data: records, meta: pagy_metadata(pagy))
      end

      def show
        @borrowing = Borrowing.find(params[:id])
        authorize @borrowing
        render_response(data: @borrowing)
      end

      def create
        @borrowing = current_user.borrowings.build(borrowing_params)
        authorize @borrowing

        if @borrowing.save
          render_response(data: @borrowing, status: :created)
        else
          render_error(message: @borrowing.errors.full_messages, status: :unprocessable_entity,
                       code: :unprocessable_entity)
        end
      end

      def update
        @borrowing = Borrowing.find(params[:id])
        authorize @borrowing

        if @borrowing.update(borrowing_params)
          render_response(data: @borrowing)
        else
          render_error(message: @borrowing.errors.full_messages, status: :unprocessable_entity,
                       code: :unprocessable_entity)
        end
      end

      def return_book
        @borrowing = Borrowing.find(params[:id])
        authorize @borrowing, :return_book?

        if @borrowing.update(returned_at: Time.current, status: :returned)
          render_response(data: @borrowing)
        else
          render_error(message: @borrowing.errors.full_messages, status: :unprocessable_entity,
                       code: :unprocessable_entity)
        end
      end

      private

      def borrowing_params
        params.require(:borrowing).permit(:book_id)
      end
    end
  end
end
