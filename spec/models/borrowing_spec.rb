# frozen_string_literal: true

require "rails_helper"

RSpec.describe Borrowing, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:book) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(active: 0, returned: 1).with_default(:active) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:borrowed_at) }
    it { is_expected.to validate_presence_of(:due_at) }
  end

  describe "custom validations" do
    let(:borrowing) { FactoryBot.build(:borrowing, borrowed_at: Time.current, due_at: 3.weeks.from_now) }

    it "validates due_at is exactly 2 weeks after borrowed_at" do
      borrowing.valid?
      expect(borrowing.errors[:due_at]).to include("must be exactly 2 weeks after borrowed_at")
    end

    it "is valid when due_at is exactly 2 weeks after borrowed_at" do
      borrowing.due_at = borrowing.borrowed_at + 2.weeks
      expect(borrowing).to be_valid
    end
  end

  describe "callbacks" do
    it "sets due_at to 2 weeks after borrowed_at on creation" do
      borrowing = FactoryBot.create(:borrowing, borrowed_at: Time.current, due_at: nil)
      expect(borrowing.due_at).to eq(borrowing.borrowed_at + 2.weeks)
    end
  end
end
