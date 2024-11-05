module Cdss
  module Parsers
    module StationParser
      extend BaseParser

      class << self
        def parse_stations(response)
          parse_collection(response)
        end

        private

        def build_resource(data)
          Cdss::Models::Station.new(
            station_num: data['stationNum'],
            abbrev: data['abbrev'],
            usgs_site_id: data['usgsSiteId'],
            name: data['stationName'],
            agency: data['dataSource'],
            latitude: data['latitude'],
            longitude: data['longitude'],
            division: data['division'],
            water_district: data['waterDistrict'],
            county: data['county'],
            state: data['state'],
            utm_x: data['utmX'],
            utm_y: data['utmY'],
            location_accuracy: data['locationAccuracy'],
            start_date: parse_timestamp(data['startDate']),
            end_date: parse_timestamp(data['endDate']),
            modified: parse_timestamp(data['modified']),
            more_information: data['moreInformation'],
            meas_unit: data['measUnit'],
            metadata: {}
          )
        end
      end
    end
  end
end
