source "https://rubygems.org"

# Load shared rampart version
require_relative "config/rampart_version" if File.exist?(File.expand_path("config/rampart_version.rb", __dir__))
RAMPART_VERSION ||= ">= 0"

gem "rails", "~> 7.0"

gem "packwerk", "~> 3.2", group: :development

gem "rampart-core", RAMPART_VERSION
