# frozen_string_literal: true

require 'faker'

puts 'Cleaning database...'
Borrowing.destroy_all
Book.destroy_all
User.destroy_all

puts 'Creating users...'
# Create usage-specific users
User.create!(
  email: 'librarian@example.com',
  password: 'password',
  role: :librarian
)

member = User.create!(
  email: 'member@example.com',
  password: 'password',
  role: :member
)

# Create some random members
10.times do
  User.create!(
    email: Faker::Internet.unique.email,
    password: 'password',
    role: :member
  )
end

puts 'Creating books...'
books = []
20.times do
  books << Book.create!(
    title: Faker::Book.title,
    author: Faker::Book.author,
    genre: Faker::Book.genre,
    isbn: Faker::Code.unique.isbn,
    total_copies: rand(1..5)
  )
end

puts 'Creating borrowings...'
# Active borrowings for the main member
3.times do
  Borrowing.create!(
    user: member,
    book: books.sample,
    status: :active
  )
end

# Returned borrowings for the main member
2.times do
  b = Borrowing.create!(
    user: member,
    book: books.sample,
    status: :active
  )
  b.update!(status: :returned, returned_at: Time.current)
end

puts "Done! Created #{User.count} users, #{Book.count} books, and #{Borrowing.count} borrowings."
puts "Librarian: librarian@example.com / password"
puts "Member: member@example.com / password"
