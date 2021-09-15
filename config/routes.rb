# frozen_string_literal: true

require "sidekiq/web"
require "sidekiq/cron/web"

Rails.application.routes.draw do
  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  mount Decidim::Core::Engine => "/"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # recreates the /processes route for /any-alternative, reusing the same controllers
  # content will be differentiatied automatically by scoping selectively all SQL queries depending if a process is in a group or not
  if Rails.application.secrets.scope_ungrouped_processes[:enabled]
    path = ParticipatoryProcessesScoper::ALTERNATIVE_NAMESPACE
    resources path, only: [:index, :show], param: :slug, path: path, controller: "decidim/participatory_processes/participatory_processes" do
      get "all-metrics", on: :member
      resources :participatory_process_steps, only: [:index], path: "steps"
      resource :widget, only: :show, path: "embed"
    end

    scope "/#{path}/:participatory_process_slug/f/:component_id" do
      Decidim.component_manifests.each do |manifest|
        next unless manifest.engine

        constraints Decidim::ParticipatoryProcesses::CurrentComponent.new(manifest) do
          mount manifest.engine, at: "/", as: "decidim_participatory_process_#{manifest.name}"
        end
      end
    end
  end

  mount Managers::Admin::AdminEngine => "/admin/managers"
end
