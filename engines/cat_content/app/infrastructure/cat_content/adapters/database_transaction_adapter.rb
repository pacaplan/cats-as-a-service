# frozen_string_literal: true

module CatContent
  module Infrastructure
    module Adapters
      class DatabaseTransactionAdapter < Ports::TransactionPort
        def transaction(&block)
          ActiveRecord::Base.transaction(&block)
        end
      end
    end
  end
end
