# frozen_string_literal: true

module RequestEntryPoint
  module Books
    class ListBooks < BaseService
      def call
        books = context.scope

        if context.query.present?
          sanitized_query = "%#{sanitize_sql_like(context.query)}%"
          books = books.where(
            'title ILIKE :q OR author ILIKE :q OR genre ILIKE :q',
            q: sanitized_query
          )
        end

        context.books = books
      end

      private

      def sanitize_sql_like(string)
        string.gsub(/[%_\\]/) { |match| "\\#{match}" }
      end
    end
  end
end
