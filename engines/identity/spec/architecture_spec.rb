# frozen_string_literal: true

require "rails_helper"
require "rampart/testing/engine_architecture_shared_spec"

RSpec.describe "Identity Engine Architecture", type: :architecture do
  it_behaves_like "Rampart Engine Architecture",
    engine_root: File.expand_path("..", __dir__),
    container_class: Identity::Container
end
