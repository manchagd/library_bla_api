# frozen_string_literal: true

module Api
  module V1
    class BooksController < ApplicationController
      before_action :authenticate_request!
      after_action :verify_authorized, except: :index
      after_action :verify_policy_scoped, only: :index

      def index
        @books = policy_scope(Book)
        authorize Book # Policy scope check is separate, but we can authorize the action generally

        pagy, records = pagy(@books)
        render_response(data: records, meta: pagy_metadata(pagy))
      end

      def show
        @book = Book.find(params[:id])
        authorize @book
        render_response(data: @book)
      end

      def create
        @book = Book.new(book_params)
        authorize @book

        if @book.save
          render_response(data: @book, status: :created)
        else
          render_error(message: @book.errors.full_messages, status: :unprocessable_entity, code: :unprocessable_entity)
        end
      end

      def update
        @book = Book.find(params[:id])
        authorize @book

        if @book.update(book_params)
          render_response(data: @book)
        else
          render_error(message: @book.errors.full_messages, status: :unprocessable_entity, code: :unprocessable_entity)
        end
      end

      def destroy
        @book = Book.find(params[:id])
        authorize @book
        @book.destroy
        head :no_content
      end

      private

      def book_params
        params.require(:book).permit(:title, :author, :genre, :isbn, :total_copies)
      end
    end
  end
end
