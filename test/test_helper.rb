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
  config.allow_http_connections_when_no_cassette = false

  # Automatically delete cassettes if response is 404 or body is empty
  config.after_http_request do |request, response|
    if response&.status&.code == 404 || response&.body.nil? || response&.body.empty?
      cassette_path = VCR.current_cassette&.file
      if cassette_path && File.exist?(cassette_path)
        File.delete(cassette_path)
        puts "Deleted cassette: #{cassette_path} (due to 404 or empty response)"
      end
    end
  end
end

Cdss.config.user_agent = -> { "Cdss Test" }
