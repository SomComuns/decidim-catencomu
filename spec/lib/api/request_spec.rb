# frozen_string_literal: true

require "rails_helper"

describe "Decidim::Civicrm::Api::Request", type: :class do
  subject { Decidim::Civicrm::Api::Request.new }

  describe "#get_user" do
    context "when user exists" do
      it "returns a valid user" do
        stub_user_valid_request
        expect(subject.get_user(42, with_contact: false)).to eq({
          "id" => "42",
          "name" => "arthur.dent",
          "email" => "arthurdent@example.com",
          "contact_id" => "9999"
        })
      end
    end

    context "when user does not exist" do
      it "returns blank" do
        stub_user_not_found_request
        expect(subject.get_user(42, with_contact: false)).to be_blank
      end
    end

    context "when response is malformed" do
      it "raises an error" do
        stub_user_invalid_request
        expect { subject.get_user(42, with_contact: false) }.to raise_error Decidim::Civicrm::Api::Error
      end
    end
  end
end