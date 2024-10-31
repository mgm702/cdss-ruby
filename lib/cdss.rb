require 'zeitwerk'
require 'dry-configurable'
require 'httparty'
require 'json'

module Cdss
  loader = Zeitwerk::Loader.for_gem
  loader.setup

  extend Dry::Configurable

  setting :base_url, default: "https://dwr.state.co.us/Rest/GET/api/v2"
  setting :default_parameter, default: "DISCHRG"
end
