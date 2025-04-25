# frozen_string_literal: true

require "rails_helper"

describe ParticipatoryProcessesScoper do
  let(:app) { ->(env) { [200, env, "app"] } }
  let(:env) { Rack::MockRequest.env_for("https://#{host}/#{path}?foo=bar", "decidim.current_organization" => organization) }
  let(:host) { "city.domain.org" }
  let(:middleware) { described_class.new(app) }
  let(:path) { "some_path" }
  let!(:organization) { create(:organization, host:) }
  let!(:process_group) { create :participatory_process_group, organization: }
  let!(:other_organization) { create(:organization, host: "another.host.org") }
  let!(:external_process) { create(:participatory_process, slug: "external-slug", organization: other_organization) }
  let!(:alternative_process) { create(:participatory_process, slug: "alternative-slug", organization:) }
  let!(:normal_process) { create(:participatory_process, slug: "normal-slug", organization:, participatory_process_group: process_group) }

  let(:route) { "global_processes" }
  let(:enabled) { true }

  before do
    Rails.application.secrets.scope_ungrouped_processes[:enabled] = enabled
    Decidim::ParticipatoryProcess.scope_groups_mode(nil, nil)
  end

  shared_examples "same environment" do
    it "do not modify the environment" do
      code, new_env = middleware.call(env)

      expect(new_env).to eq(env)
      expect(code).to eq(200)
    end

    it "has current organization in env" do
      _code, new_env = middleware.call(env)

      expect(new_env["decidim.current_organization"]).to eq(env["decidim.current_organization"])
    end
  end

  shared_examples "untampered participatory_process model" do
    it "participatory_process model is not tampered" do
      # ensure model is always reset after calling the middleware
      Decidim::ParticipatoryProcess.scope_groups_mode(:include, "some_route")
      middleware.call(env)

      expect(Decidim::ParticipatoryProcess.scoped_groups_namespace).not_to be_present
      expect(Decidim::ParticipatoryProcess.scoped_groups_mode).not_to be_present
    end
  end

  shared_examples "unaffected routes" do
    context "when path is the home" do
      let(:path) { "" }

      it_behaves_like "same environment"
      it_behaves_like "untampered participatory_process model"
    end

    context "when path any other" do
      let(:path) { "another_path" }

      it_behaves_like "same environment"
      it_behaves_like "untampered participatory_process model"
    end
  end

  shared_examples "exclude grouped processes" do
    it_behaves_like "same environment"

    it "participatory_process model is tampered with exclude" do
      middleware.call(env)

      expect(path).to match(/^#{Decidim::ParticipatoryProcess.scoped_groups_namespace}/)
      expect(Decidim::ParticipatoryProcess.scoped_groups_mode).to eq(:exclude)
    end

    it "participatory_process queries only non grouped processes" do
      middleware.call(env)

      expect(Decidim::ParticipatoryProcess.find_by(id: alternative_process.id)).not_to be_present
      expect(Decidim::ParticipatoryProcess.find_by(id: normal_process.id)).to eq(normal_process)
    end
  end

  shared_examples "include grouped processes" do
    it_behaves_like "same environment"

    it "participatory_process model is tampered with include non grouped processes" do
      middleware.call(env)

      expect(path).to match(/^#{Decidim::ParticipatoryProcess.scoped_groups_namespace}/)
      expect(Decidim::ParticipatoryProcess.scoped_groups_mode).to eq(:include)
    end

    it "participatory_process queries only specified non grouped processes" do
      middleware.call(env)

      expect(Decidim::ParticipatoryProcess.find_by(id: alternative_process.id)).to eq(alternative_process)
      expect(Decidim::ParticipatoryProcess.find_by(id: normal_process.id)).not_to be_present
    end
  end

  context "when ungrouped processes not configured" do
    let(:enabled) { false }

    it_behaves_like "unaffected routes"
  end

  context "when ungrouped process configured" do
    it_behaves_like "unaffected routes"

    context "and default processes path" do
      let(:path) { "processes" }

      it_behaves_like "exclude grouped processes"

      context "and correct participatory_process" do
        let(:path) { "processes/#{normal_process.slug}" }

        it_behaves_like "exclude grouped processes"

        it "do not redirect" do
          code, new_env = middleware.call(env)

          expect(new_env["Location"]).not_to be_present
          expect(code).to eq(200)
        end
      end

      context "and incorrect participatory_process" do
        let(:path) { "processes/#{alternative_process.slug}" }

        it_behaves_like "untampered participatory_process model"

        it "redirects" do
          code, new_env = middleware.call(env)

          expect(new_env["Location"]).to eq("/#{route}/#{alternative_process.slug}")
          expect(code).to eq(301)
        end
      end
    end

    context "and processes alternative index" do
      let(:path) { route }

      it_behaves_like "include grouped processes"

      context "and correct participatory_process" do
        let(:path) { "#{route}/#{alternative_process.slug}" }

        it_behaves_like "include grouped processes"

        it "do not redirect" do
          code, new_env = middleware.call(env)

          expect(new_env["Location"]).not_to be_present
          expect(code).to eq(200)
        end
      end

      context "and incorrect participatory_process" do
        let(:path) { "#{route}/#{normal_process.slug}" }

        it_behaves_like "untampered participatory_process model"

        it "redirects" do
          code, new_env = middleware.call(env)

          expect(new_env["Location"]).to eq("/processes/#{normal_process.slug}")
          expect(code).to eq(301)
        end
      end
    end

    context "when participatory_process from other organization" do
      let(:path) { "processes/#{external_process.slug}" }

      it_behaves_like "same environment"
      it_behaves_like "untampered participatory_process model"

      it "participatory_process is not found" do
        _code, _new_env = middleware.call(env)

        expect(middleware.send(:find_participatory_process)).to be_nil
      end
    end
  end
end
