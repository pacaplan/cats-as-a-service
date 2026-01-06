source "https://rubygems.org"

gem "rails", "~> 7.0"

gem "packwerk", "~> 3.2", group: :development

# Load shared rampart version
require_relative "config/rampart_version" if File.exist?(File.expand_path("config/rampart_version.rb", __dir__))
RAMPART_VERSION ||= ">= 0"

if ENV["LOCAL_RAMPART"]
  gem "rampart-core", path: "../rampart"
else
  gem "rampart-core", RAMPART_VERSION
end
