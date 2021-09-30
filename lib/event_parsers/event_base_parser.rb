# frozen_string_literal: true

module EventParsers
  class EventBaseParser
    attr_reader :errors, :resource, :resource_id, :resource_type, :entity, :action

    def data
      {
        entity: @entity,
        action: @action,
        json: 1
      }.merge(json)
    end

    def valid?
      @errors = {}
      @errors[:resource] = "Resouce is missing" if @resource.blank?
      @errors[:resource_id] = "Resouce is missing" if @resource_id.blank?

      @errors.blank?
    end
  end
end
