# frozen_string_literal: true

module CatContent
  module Ports
    class EventBusPort < Rampart::Ports::SecondaryPort
      abstract_method :publish
    end
  end
end
