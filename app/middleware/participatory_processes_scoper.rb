# frozen_string_literal: true

# Provides a way for the application to scope participatory_processes depending on their type
# A url scope will be generated for every alternative process type that needs its own
# section, (e.g `/processes` and `/general_assemblies`)
#
# It also manages redirects for individual participatory_processes to the proper url path if the
# requested participatory_process belongs into another scope:
# (e.g `processes/alternative-participatory_process-slug` > `alternative/alternative-participatory_process-slug`)
class ParticipatoryProcessesScoper
  DEFAULT_NAMESPACE = "processes"
  ALTERNATIVE_NAMESPACE = "global_processes"

  def initialize(app)
    @app = app
  end

  def call(env)
    @request = Rack::Request.new(env)

    return @app.call(env) unless @request.get? # only run middleware for GET requests

    reset_participatory_process_model_default_scope

    @organization = env["decidim.current_organization"]
    @request_path_parts = request_path_parts
    @current_participatory_process = find_participatory_process

    return @app.call(env) if out_of_scope?

    if requesting_default_processes?
      return redirect(ALTERNATIVE_NAMESPACE) if alternative_current_participatory_process?

      exclude_alternative_participatory_processes_from_default_scope
    elsif requesting_alternative_processes?
      return redirect(DEFAULT_NAMESPACE) if normal_current_participatory_process?

      exclude_normal_participatory_processes_from_default_scope
    end

    @app.call(env)
  end

  private

  def reset_participatory_process_model_default_scope
    Decidim::ParticipatoryProcess.scope_groups_mode(nil, nil)
  end

  # From "/groups/slug3" to ["", "groups", "slug3"]
  def request_path_parts
    @request.path.split("/")
  end

  def request_namespace
    @request_path_parts[1]
  end

  def request_slug
    @request_path_parts[2]
  end

  def find_participatory_process
    return unless @organization && request_slug

    Decidim::ParticipatoryProcess
      .unscoped
      .select(:id, :slug, :decidim_participatory_process_group_id)
      .where(organization: @organization)
      .find_by("slug LIKE ?", "#{request_slug}%")
  end

  def scope_groups?
    Rails.application.secrets.scope_ungrouped_processes[:enabled]
  end

  def out_of_scope?
    !scope_groups? || request_slug && @current_participatory_process.blank?
  end

  def requesting_default_processes?
    request_namespace == DEFAULT_NAMESPACE
  end

  def requesting_alternative_processes?
    request_namespace == ALTERNATIVE_NAMESPACE
  end

  def alternative_current_participatory_process?
    @current_participatory_process && @current_participatory_process&.decidim_participatory_process_group_id.blank?
  end

  def normal_current_participatory_process?
    @current_participatory_process && @current_participatory_process&.decidim_participatory_process_group_id.present?
  end

  def exclude_alternative_participatory_processes_from_default_scope
    Decidim::ParticipatoryProcess.scope_groups_mode(:exclude, request_namespace)
  end

  def exclude_normal_participatory_processes_from_default_scope
    Decidim::ParticipatoryProcess.scope_groups_mode(:include, request_namespace)
  end

  def redirect(namespace)
    [301, { "Location" => location(namespace), "Content-Type" => "text/html", "Content-Length" => "0" }, []]
  end

  def location(namespace)
    parts = request_path_parts
    parts[1] = namespace
    parts.join("/")
  end
end
