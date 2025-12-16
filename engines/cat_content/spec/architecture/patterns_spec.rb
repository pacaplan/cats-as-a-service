# frozen_string_literal: true

require "rails_helper"
require "rampart/testing"

RSpec.describe "Architecture::Patterns", type: :architecture, skip_db: true do
  it_behaves_like "Rampart Engine Architecture",
    engine_root: File.expand_path("../../..", __FILE__),
    container_class: CatContent::Infrastructure::Wiring::Container
end
