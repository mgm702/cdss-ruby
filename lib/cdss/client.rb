# frozen_string_literal: true

module Cdss
  # Main client class for interacting with the CDSS API.
  #
  # The Client class provides access to all CDSS API endpoints and handles authentication,
  # request configuration, and response processing.
  #
  # @example Create a new client
  #   client = Cdss::Client.new(api_key: "your-api-key")
  #   client.get_climate_stations(county: "Denver")
  class Client
    include HTTParty

    base_uri Cdss.config.base_url

    include AdminCalls
    include Analysis
    include Climate
    include GroundWater
    include Structures
    include SurfaceWater
    include Telemetry
    include WaterRights
    include ReferenceTables

    # @return [Hash] Additional options passed to the client
    attr_reader :options

    # @return [String, nil] API key for authentication
    attr_reader :api_key

    # Initialize a new CDSS API client.
    #
    # @param [String, nil] api_key API key for authentication
    # @param [Hash] options Additional options for configuring the client
    # @return [Client] New client instance
    def initialize(api_key: nil, **options)
      @options = options
      @api_key = api_key
      setup_client
    end

    # Update the client's API key.
    #
    # @param [String] key New API key
    # @return [String] The new API key
    def api_key=(key)
      @api_key = key
      setup_client
    end

    private

    # Configures the HTTP client with timeout and authorization headers.
    # Sets the User-Agent and API token if provided.
    #
    # @return [void]
    def setup_client
      self.class.default_timeout(Cdss.config.timeout)
      self.class.headers({
        "User-Agent" => Cdss.config.user_agent,
        "Token" => api_key
      }.compact)
    end

    # Processes API responses and handles error conditions.
    #
    # @param [HTTParty::Response] response The raw API response
    # @return [Hash] Parsed JSON response body
    # @raise [RuntimeError] When the API request fails
    def handle_response(response)
      return JSON.parse(response.body) if response.success?

      raise "API request failed with status #{response.code}: #{response.message}"
    end

    # Makes GET requests with debug logging support.
    #
    # @param [Array] args The request arguments including path and options
    # @return [HTTParty::Response] The API response
    def self.get(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      debug_request(args.first, options)
      super(*args, options)
    end

    # Makes authenticated GET requests to the API.
    #
    # @param [String] path The API endpoint path
    # @param [Hash] options Request options including query parameters
    # @return [HTTParty::Response] The API response
    def get(path, options = {})
      options[:query] ||= {}
      options[:query][:apiKey] = api_key if api_key
      self.class.get(path, options)
    end

    # Logs detailed request information when debug mode is enabled.
    #
    # @param [String] endpoint The API endpoint being called
    # @param [Hash] options Request options including query parameters and headers
    # @return [void]
    def self.debug_request(endpoint, options)
      return unless Cdss.config.debug

      query_string = options[:query]&.map { |k, v| "#{k}=#{v}" }&.join("&")
      full_url = [base_uri, endpoint].join
      full_url += "?#{query_string}" if query_string

      puts "\n=== CDSS API Request ==="
      puts "URL: #{full_url}"
      puts "\nHeaders:"
      headers = default_options[:headers] || {}
      headers.merge!(options[:headers] || {})
      headers.each do |key, value|
        puts "  #{key}: #{value}"
      end
      puts "=====================\n"
    end
  end
end
