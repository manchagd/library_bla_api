# frozen_string_literal: true

require "rails_helper"

RSpec.describe Book, type: :model do
  describe "validations" do
    subject { FactoryBot.build(:book) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:author) }
    it { is_expected.to validate_presence_of(:genre) }
    it { is_expected.to validate_presence_of(:isbn) }
    it { is_expected.to validate_presence_of(:total_copies) }

    it { is_expected.to validate_uniqueness_of(:isbn).case_insensitive }
    it { is_expected.to validate_numericality_of(:total_copies).is_greater_than_or_equal_to(0).only_integer }
  end

  describe "associations" do
    it { is_expected.to have_many(:borrowings).dependent(:restrict_with_error) }
  end
end
