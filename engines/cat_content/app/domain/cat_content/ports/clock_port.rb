# frozen_string_literal: true

module CatContent
  module Ports
    class ClockPort < Rampart::Ports::SecondaryPort
      abstract_method :now
    end
  end
end
