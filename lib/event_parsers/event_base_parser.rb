# frozen_string_literal: true

module EventParsers
  class EventBaseParser
    attr_reader :errors, :resource, :resource_id, :resource_type, :entity, :action, :model_class
    attr_accessor :result

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
      @errors[:resource_id] = "Resouce id is missing" if @resource_id.blank?
      @errors[:result] = "Result id is missing" if result.blank? || result["id"].blank?

      @errors.blank?
    end

    def json
      raise NotImplementedError
    end

    def save!
      raise NotImplementedError
    end
  end
end
