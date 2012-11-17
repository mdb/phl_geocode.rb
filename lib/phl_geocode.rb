require "json"
require "open-uri"
require "net/http"

class PHLGeocode
  attr_accessor :response
  attr_accessor :settings

  def initialize(options={})
    @settings = {
      :min_confidence => 81,
      :api_base => "http://services.phila.gov/ULRS311/Data/Location/"
    }.merge(options)
  end

  def get_coordinates(address=nil)
    raise ArgumentError("Argument must be a string") unless address.is_a? String
    @response ||= call_api(address)
    parse_locations(@response)
  end

  private
  def parse_locations(response)
    locations_json = JSON.parse(response.body)["Locations"]

    locations_json.find_all { |loc|
      loc["Address"]["Similarity"] >= @settings[:min_confidence]
    }.map { |item|
      {
      :address => item["Address"]["StandardizedAddress"],
      :similarity => item["Address"]["Similarity"],
      :latitude => item["YCoord"],
      :longitude => item["XCoord"]
      }
    }
  end

  def call_api(address)
    addr = URI::encode(address)
    Net::HTTP.get_response(URI.parse("#{@settings[:api_base]}#{addr}"))
  end
end
