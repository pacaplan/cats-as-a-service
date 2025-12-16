# frozen_string_literal: true

module CatContent
  module Infrastructure
    module Adapters
      class SystemClockAdapter < Ports::ClockPort
        def now
          Time.now
        end
      end
    end
  end
end
