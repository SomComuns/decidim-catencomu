# frozen_string_literal: true

require "rails_helper"

module Decidim
  module Civicrm
    describe VerificationJob do
      let!(:user) { create(:user) }
      let!(:identity) { create(:identity, provider: "civicrm", user: user) }

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
        context "when authorization is created with success" do
          it "notifies the user for the success" do
            stub_rectify_publisher("Decidim::Verifications::AuthorizeUser", :call, :ok)
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.verifications.civicrm.ok",
                event_class: Decidim::Civicrm::VerificationSuccessNotification,
                resource: user,
                extra: {
                  status: :ok,
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
                event: "decidim.verifications.civicrm.invalid",
                event_class: Decidim::Civicrm::VerificationInvalidNotification,
                resource: user,
                extra: {
                  status: :invalid,
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
