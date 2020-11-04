# frozen_string_literal: true

require "rails_helper"

module Decidim
  module Civicrm
    describe VerificationJob do
      class TestRectifyPublisher < Rectify::Command
        include Wisper::Publisher
        def initialize(*args); end
      end
      def stub_rectify_publisher(clazz, called_method, event_to_publish, *published_event_args)
        stub_const(clazz, Class.new(TestRectifyPublisher) do
          define_method(called_method) do |*_args|
            publish(event_to_publish, *published_event_args)
          end
        end)
      end

      context "when omniauth_registration event is notified" do
        let!(:user) { create(:user) }
        let!(:identity) { create(:identity, provider: "civicrm", user: user) }
  
        context "when user does not have an identity for civicrm" do
          let!(:identity) { create(:identity, provider: "none", user: user) }

          it "does nothing" do
            stub_rectify_publisher("Decidim::Verifications::AuthorizeUser", :call, :ok)
            expect(Decidim::EventsManager).not_to receive(:publish)
            VerificationJob.new.perform(user.id)
          end
        end

        context "when authorization is created with success" do
          it "notifies the user for the success" do
            stub_rectify_publisher("Decidim::Verifications::AuthorizeUser", :call, :ok)
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.civicrm_verification.ok",
                event_class: Decidim::Civicrm::VerificationSuccessNotification,
                resource: user,
                affected_users: [user],
                extra: {
                  status: "ok",
                  errors: []
                }
              )

            VerificationJob.new.perform(user.id)
          end
        end

        context "when authorization creation fails" do
          it "notifies the user for the failure" do
            stub_rectify_publisher("Decidim::Verifications::AuthorizeUser", :call, :invalid)
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.civicrm_verification.invalid",
                event_class: Decidim::Civicrm::VerificationInvalidNotification,
                resource: user,
                affected_users: [user],
                extra: {
                  status: "invalid",
                  errors: []
                }
              )

            VerificationJob.new.perform(user.id)
          end
        end
      end
    end
  end
end
