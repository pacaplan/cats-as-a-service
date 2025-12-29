# frozen_string_literal: true

require "rails_helper"
require "rampart/testing/engine_architecture_shared_spec"

RSpec.describe "CatContent Engine Architecture", type: :architecture do
  it_behaves_like "Rampart Engine Architecture",
    engine_root: File.expand_path("..", __dir__),
    container_class: CatContent::Infrastructure::Wiring::Container
end
