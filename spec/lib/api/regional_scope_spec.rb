# frozen_string_literal: true
# frozen_string_literal: true

require "rails_helper"

describe "Decidim::Civicrm::Api::RegionalScope", type: :class do
  subject { Decidim::Civicrm::Api::RegionalScope }

  describe "FIELD_ID" do
    it "is 23" do
      expect(subject::FIELD_ID).to eq(23)
    end
  end

  describe "FIELD_NAME" do
    it "is custom_23" do
      expect(subject::FIELD_NAME).to eq("custom_23")
    end
  end

  describe "ALL" do
    it "is a hash" do
      expect(subject::ALL).to be_a(Hash)
    end

    it "is has 12 elements" do
      expect(subject::ALL.count).to eq(12)
    end
  end
end
