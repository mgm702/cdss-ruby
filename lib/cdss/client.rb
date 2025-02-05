module Cdss
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

    attr_reader :options, :api_key

    def initialize(api_key: nil, **options)
      @options = options
      @api_key = api_key
      setup_client
    end

    def api_key=(key)
      @api_key = key
      setup_client
    end

    private

    def setup_client
      self.class.default_timeout(Cdss.config.timeout)
      self.class.headers({
        'User-Agent' => Cdss.config.user_agent,
        'Token' => api_key
      }.compact)
    end

    def handle_response(response)
      return JSON.parse(response.body) if response.success?
      raise "API request failed with status #{response.code}: #{response.message}"
    end

    def self.get(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      debug_request(args.first, options)
      super(*args, options)
    end

    def get(path, options = {})
      options[:query] ||= {}
      options[:query][:apiKey] = api_key if api_key
      self.class.get(path, options)
    end

    def self.debug_request(endpoint, options)
      if Cdss.config.debug
        query_string = options[:query]&.map { |k,v| "#{k}=#{v}" }&.join('&')
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
end
