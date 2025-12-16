# frozen_string_literal: true

module CatContent
  module Ports
    class IdGeneratorPort < Rampart::Ports::SecondaryPort
      abstract_method :generate
    end
  end
end
