# frozen_string_literal: true

require "zeitwerk"
require "dry-configurable"
require "httparty"
require "json"

module Cdss
  @loader = Zeitwerk::Loader.for_gem
  @loader.enable_reloading
  @loader.setup

  extend Dry::Configurable
  setting :user_agent, default: -> { "Cdss Ruby Gem/#{VERSION}" }
  setting :timeout, default: 30
  setting :base_url, default: "https://dwr.state.co.us/Rest/GET/api/v2"
  setting :default_parameter, default: "DISCHRG"
  setting :debug, default: false

  class << self
    attr_reader :loader

    def client(**options)
      Cdss::Client.new(**options)
    end
  end
end
