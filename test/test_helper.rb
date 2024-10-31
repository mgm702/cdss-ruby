# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "cdss"

require "minitest/autorun"
require "minitest/reporters"
require "webmock/minitest"
require "vcr"

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

VCR.configure do |config|
  config.cassette_library_dir = 'test/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.ignore_localhost = true
end

Cdss.config.user_agent = -> { "Cdss Test" }
