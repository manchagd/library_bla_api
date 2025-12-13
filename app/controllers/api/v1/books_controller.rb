# frozen_string_literal: true

module Api
  module V1
    class BooksController < ApplicationController
      before_action :authenticate_request!
      after_action :verify_authorized, except: :index
      after_action :verify_policy_scoped, only: :index

      def index
        authorize Book
        result = RequestEntryPoint::Books::ListBooks.call(
          scope: policy_scope(Book),
          query: params[:query]
        )

        pagy, records = pagy(result.books)
        render_response(data: BookBlueprint.render_as_hash(records), meta: pagy_metadata(pagy))
      end

      def show
        authorize book
        render_response(data: BookBlueprint.render_as_hash(book))
      end

      def create
        authorize Book
        result = RequestEntryPoint::Books::CreateBook.call(book_params: book_params)

        if result.success?
          render_response(data: BookBlueprint.render_as_hash(result.book), status: :created)
        else
          render_error(message: result.message, status: :unprocessable_entity, code: :unprocessable_entity)
        end
      end

      def update
        authorize book
        result = RequestEntryPoint::Books::UpdateBook.call(book_id: params[:id], book_params: book_params)

        if result.success?
          render_response(data: BookBlueprint.render_as_hash(result.book))
        else
          render_error(message: result.message, status: :unprocessable_entity, code: :unprocessable_entity)
        end
      end

      def destroy
        authorize book
        RequestEntryPoint::Books::DeleteBook.call(book_id: params[:id])
        head :no_content
      end

      private

      def book
        @book ||= Book.find(params[:id])
      end

      def book_params
        params.require(:book).permit(:title, :author, :genre, :isbn, :total_copies)
      end
    end
  end
end
