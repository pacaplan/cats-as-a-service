# frozen_string_literal: true

module CatContent
  # Domain exception for when a resource is not found
  class ResourceNotFound < Rampart::Domain::DomainException
    attr_reader :resource_type, :identifier

    def initialize(resource_type:, identifier:)
      @resource_type = resource_type
      @identifier = identifier
      super("#{resource_type} not found: #{identifier}")
    end
  end
end

