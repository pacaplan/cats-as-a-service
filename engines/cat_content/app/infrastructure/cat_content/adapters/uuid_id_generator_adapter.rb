# frozen_string_literal: true

require 'securerandom'

module CatContent
  module Infrastructure
    module Adapters
      class UuidIdGeneratorAdapter < Ports::IdGeneratorPort
        def generate
          SecureRandom.uuid
        end
      end
    end
  end
end
