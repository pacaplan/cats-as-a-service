# frozen_string_literal: true

module CatContent
  module Ports
    class CustomCatRepository < Rampart::Ports::SecondaryPort
      abstract_method :add, :find, :find_by_user_and_id, :list_all, :list_by_user, :update, :remove

      def list_by_user(user_id:, page:, per_page:, include_archived: false)
        raise NotImplementedError
      end
    end
  end
end
