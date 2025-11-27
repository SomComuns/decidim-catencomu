# frozen_string_literal: true

require "rails_helper"

module Decidim::Civicrm
  describe Group do
    subject { described_class.new(organization:, civicrm_group_id: 1, title: "Group") }

    let!(:organization) { create(:organization) }
    let!(:group_config) { Decidim::CatcomuManagers::GroupConfig.create!(civicrm_default_group: subject) }

    it { is_expected.to be_valid }

    context "when the group is deleted" do
      it "removes the association from the group config" do
        expect { subject.destroy }.to change { group_config.reload.civicrm_default_group }.to(nil)
      end
    end
  end
end
