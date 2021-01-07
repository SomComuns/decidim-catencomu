# frozen_string_literal: true

require "rails_helper"

describe "Decidim::Civicrm::Api::User", type: :class do
  subject { Decidim::Civicrm::Api::User }

  describe "#from_contact" do
    let(:contact_json) do
      {
        "contact_id" => 9999,
        "email" => "arthurdent@example.com",
        "display_name" => "Sir Arthur Dent",
        "name" => "arthur_dent",
        "roles" => {
          "7" => "inscribed"
        },
        "api_Address_get" => {
          "values" => [
            "custom_23" => "AT000"
          ]
        }
      }
    end

    it "returns a well-formed user hash" do
      expected = {
        contact_id: 9999,
        email: "arthurdent@example.com",
        name: "Sir Arthur Dent",
        nickname: "arthur_dent",
        role: :inscribed,
        regional_scope: "AT000"
      }

      expect(subject.from_contact(contact_json)).to eq(expected)
    end
  end

  describe "#from_user" do
    let(:user_json) do
      {
        "id" => 42,
        "contact_id" => 9999,
        "email" => "arthurdent@example.com"
      }
    end

    it "returns a well-formed user hash" do
      expected = {
        id: 42,
        contact_id: 9999,
        email: "arthurdent@example.com"
      }

      expect(subject.from_user(user_json)).to eq(expected)
    end
  end
end
