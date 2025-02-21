# frozen_string_literal: true

module Cdss
  module Concerns
    # A concern module that adds log reading-related attributes to classes.
    #
    # This module provides a set of standardized attributes for log reading data,
    # including aquifer information, depth measurements, elevation, and comments.
    # When included in a class, it dynamically adds accessor methods for these attributes.
    #
    # @example Adding log reading attributes to a class
    #   class WellLog
    #     include Cdss::Concerns::LogReadingAttributes
    #   end
    module LogReadingAttributes
      # Predefined list of log reading attributes
      #
      # @return [Array<Symbol>] List of attributes related to log readings
      LOG_ATTRIBUTES = %i[
        aquifer
        g_log_top_depth
        g_log_base_depth
        g_log_top_elev
        g_log_base_elev
        g_log_thickness
        comment
      ].freeze

      # Dynamically adds accessor methods when the module is included in a class
      #
      # @param [Class] base The class including this module
      def self.included(base)
        base.class_eval do
          attr_accessor(*LOG_ATTRIBUTES)
        end
      end

      # Checks if the instance has log reading data
      #
      # @return [Boolean] true if aquifer or log thickness is present, false otherwise
      # @example Check if a well log has reading data
      #   well_log.log_reading? # => true or false
      def log_reading?
        !aquifer.nil? || !g_log_thickness.nil?
      end
    end
  end
end
