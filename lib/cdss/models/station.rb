module Cdss
  module Models
    module Station
      attr_accessor :id, :name, :agency, :latitude, :longitude, :parameters, :metadata

      def initialize(id:, name:, agency:, latitude:, longitude:, parameters:, metadata: {})
        @id = id
        @name = name
        @agency = agency
        @latitude = latitude
        @longitude = longitude
        @parameters = parameters
        @metadata = metadata
      end
    end
  end
end
