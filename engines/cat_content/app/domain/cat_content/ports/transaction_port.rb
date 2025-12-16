# frozen_string_literal: true

module CatContent
  module Ports
    class TransactionPort < Rampart::Ports::SecondaryPort
      abstract_method :transaction
    end
  end
end
