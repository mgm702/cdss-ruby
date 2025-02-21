# frozen_string_literal: true

module Cdss
  module Models
    # Base class for analysis-related models with shared functionality.
    # Provides dynamic attribute handling for call analysis, source routes,
    # and route analysis data.
    class Analysis
      class << self
        def attributes(*attrs)
          @attributes = attrs
          attr_accessor(*attrs)
        end

        def inherited(subclass)
          subclass.attributes(*@attributes) if @attributes
        end

        def attribute_list
          @attributes || []
        end
      end

      def initialize(**kwargs)
        kwargs[:metadata] ||= {}
        self.class.attribute_list.each do |attr|
          instance_variable_set(:"@#{attr}", kwargs[attr]) if kwargs.key?(attr)
        end
      end
    end

    class CallAnalysis < Analysis
      attributes :analysis_date,
                 :wdid,
                 :gnis_id,
                 :stream_mile,
                 :admin_number,
                 :percent_time_out_of_priority,
                 :downstream_call_wdid,
                 :downstream_call_right,
                 :downstream_call_stream_mile,
                 :downstream_call_admin_number,
                 :downstream_call_decreed_amount,
                 :downstream_call_decreed_unit,
                 :downstream_call_appropriation_date,
                 :downstream_call_status,
                 :modified,
                 :metadata
    end

    class SourceRoute < Analysis
      attributes :gnis_id,
                 :gnis_name,
                 :division,
                 :water_district,
                 :stream_length,
                 :tributary_to_level,
                 :tributary_to_gnis_id,
                 :tributary_gnis_name,
                 :tributary_to_stream_mile,
                 :metadata
    end

    class RouteAnalysis < Analysis
      attributes :wdid,
                 :structure_name,
                 :stream_mile,
                 :structure_type,
                 :decreed_amount,
                 :decreed_unit,
                 :appropriation_date,
                 :admin_number,
                 :modified,
                 :metadata
    end
  end
end
