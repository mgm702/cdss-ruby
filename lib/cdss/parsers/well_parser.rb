module Cdss
  module Parsers
    module WellParser
      extend BaseParser

      class << self
        def parse_wells(response)
          parse_collection(response)
        end

        def parse_well_measurements(response)
          parse_collection(response) { |data| build_measurement(data) }
        end

        def parse_geophysical_wells(response)
          parse_collection(response) { |data| build_geophysical_well(data) }
        end

        def parse_log_picks(response)
          parse_collection(response) { |data| build_log_pick(data) }
        end

        private

        def build_resource(data)
          Cdss::Models::Well.new(
            well_id: data['wellId'],
            well_name: data['wellName'],
            latitude: data['latitude'],
            longitude: data['longitude'],
            location_accuracy: data['locationAccuracy'],
            county: data['county'],
            designated_basin: data['designatedBasin'],
            management_district: data['managementDistrict'],
            division: data['division'],
            water_district: data['waterDistrict'],
            modified: parse_timestamp(data['modified']),
            metadata: {}
          )
        end

        def build_measurement(data)
          Cdss::Models::Reading.new(
            well_id: data['wellId'],
            well_name: data['wellName'],
            division: data['division'],
            water_district: data['waterDistrict'],
            county: data['county'],
            management_district: data['managementDistrict'],
            designated_basin: data['designatedBasin'],
            publication: data['publication'],
            measurement_date: parse_timestamp(data['measurementDate']),
            depth_to_water: safe_float(data['depthToWater']),
            measuring_point_above_land_surface: safe_float(data['measuringPointAboveLandSurface']),
            depth_water_below_land_surface: safe_float(data['depthWaterBelowLandSurface']),
            elevation_of_water: safe_float(data['elevationOfWater']),
            delta: safe_float(data['delta']),
            modified: parse_timestamp(data['modified']),
            data_source: data['dataSource'],
            metadata: {}
          )
        end

        def build_geophysical_well(data)
          Cdss::Models::Well.new(
            well_id: data['wellId'],
            well_name: data['wellName'],
            latitude: data['latitude'],
            longitude: data['longitude'],
            location_accuracy: data['locationAccuracy'],
            county: data['county'],
            designated_basin: data['designatedBasin'],
            management_district: data['managementDistrict'],
            division: data['division'],
            water_district: data['waterDistrict'],
            depth: safe_float(data['totalDepth']),
            elevation: safe_float(data['groundElevation']),
            modified: parse_timestamp(data['modified']),
            metadata: {}
          )
        end

        def build_log_pick(data)
          Cdss::Models::Reading.new(
            well_id: data['wellId'],
            pick_depth: safe_float(data['pickDepth']),
            formation: data['formation'],
            member: data['member'],
            pick_quality: data['pickQuality'],
            comments: data['comments'],
            modified: parse_timestamp(data['modified']),
            aquifer: data['aquifer'],
            g_log_top_depth: safe_float(data['gLogTopDepth']),
            g_log_base_depth: safe_float(data['gLogBaseDepth']),
            g_log_top_elev: safe_float(data['gLogTopElev']),
            g_log_base_elev: safe_float(data['gLogBaseElev']),
            g_log_thickness: safe_float(data['gLogThickness']),
            comment: data['comment'],
            metadata: {}
          )
        end
      end
    end
  end
end
