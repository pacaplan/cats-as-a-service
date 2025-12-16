# frozen_string_literal: true

module CatContent
  module Ports
    class LanguageModelPort < Rampart::Ports::SecondaryPort
      abstract_method :generate_description, :generate_story
    end
  end
end
