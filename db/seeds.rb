# frozen_string_literal: true

require 'faker'

def create_active_borrowings_for_member(member, books)
  rand(0..5).times do
    book = books.sample
    next if Borrowing.active.exists?(user: member, book: book)

    if rand < 0.3
      borrowed_at = rand(20..40).days.ago
      Borrowing.create!(user: member, book: book, borrowed_at: borrowed_at,
                        due_at: borrowed_at + 2.weeks, status: :active)
    else
      Borrowing.create!(user: member, book: book, status: :active)
    end
  end
end

def create_returned_borrowings_for_member(member, books)
  rand(0..3).times do
    book = books.sample
    borrowed_at = rand(30..90).days.ago
    Borrowing.create!(user: member, book: book, borrowed_at: borrowed_at,
                      due_at: borrowed_at + 2.weeks, status: :returned, returned_at: borrowed_at + rand(7..14).days)
  end
end

Rails.logger.debug 'Cleaning database...'
Borrowing.destroy_all
Book.destroy_all
User.destroy_all

Rails.logger.debug 'Creating users...'
User.create!(email: 'librarian@example.com', password: 'password', role: :librarian)
member = User.create!(email: 'member@example.com', password: 'password', role: :member)

members = [member]
100.times { members << User.create!(email: Faker::Internet.unique.email, password: 'password', role: :member) }

Rails.logger.debug 'Creating books...'
books = []
200.times do
  books << Book.create!(
    title: Faker::Book.title, author: Faker::Book.author,
    genre: Faker::Book.genre, isbn: Faker::Code.unique.isbn, total_copies: rand(1..10)
  )
end

Rails.logger.debug 'Creating borrowings...'

# Active borrowings for main member
30.times do
  book = books.sample
  Borrowing.create!(user: member, book: book, status: :active) unless Borrowing.active.exists?(user: member, book: book)
end

# Returned borrowings for main member
20.times do
  book = books.sample
  borrowed_at = rand(30..60).days.ago
  Borrowing.create!(user: member, book: book, borrowed_at: borrowed_at, due_at: borrowed_at + 2.weeks,
                    status: :returned, returned_at: rand(1..14).days.ago)
end

# Overdue borrowings for main member
5.times do
  book = books.sample
  next if Borrowing.active.exists?(user: member, book: book)

  borrowed_at = rand(20..40).days.ago
  Borrowing.create!(user: member, book: book, borrowed_at: borrowed_at, due_at: borrowed_at + 2.weeks, status: :active)
end

# Random borrowings for other members
members.reject { |m| m == member }.each do |m|
  create_active_borrowings_for_member(m, books)
  create_returned_borrowings_for_member(m, books)
end

# Borrowings due today
10.times do
  m = members.sample
  book = books.sample
  next if Borrowing.active.exists?(user: m, book: book)

  borrowed_at = 2.weeks.ago
  Borrowing.create!(user: m, book: book, borrowed_at: borrowed_at, due_at: borrowed_at + 2.weeks, status: :active)
end

active_count = Borrowing.active.count
returned_count = Borrowing.returned.count
overdue_count = Borrowing.active.where(due_at: ...Time.current).count
due_today_count = Borrowing.active.where(due_at: Time.current.all_day).count

Rails.logger.debug 'Done! Created:'
Rails.logger.debug { "  - #{User.count} users (1 librarian, #{User.member.count} members)" }
Rails.logger.debug { "  - #{Book.count} books" }
Rails.logger.debug { "  - #{Borrowing.count} borrowings (#{active_count} active, #{returned_count} returned)" }
Rails.logger.debug { "  - #{overdue_count} overdue borrowings" }
Rails.logger.debug { "  - #{due_today_count} borrowings due today" }
Rails.logger.debug ''
Rails.logger.debug 'Login credentials:'
Rails.logger.debug '  Librarian: librarian@example.com / password'
Rails.logger.debug '  Member: member@example.com / password'
