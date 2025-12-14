# frozen_string_literal: true

module CatContent
  module ValueObjects
    class Visibility < Rampart::Domain::ValueObject
      STATES = %i[public private archived].freeze

      attribute :value, Rampart::Types::Symbol.enum(*STATES)

      def public? = value == :public
      def private? = value == :private
      def archived? = value == :archived

      def to_sym = value
    end
  end
end

