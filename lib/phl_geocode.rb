require "json"
require "open-uri"
require "net/http"

class PHLGeocode
  attr_accessor :address_key_response
  attr_accessor :coordinates_response
  attr_accessor :settings

  def initialize(options={})
    @settings = {
      :min_confidence => 85,
      :api_base => "http://services.phila.gov",
      :location_path => "/ULRS311/Data/Location/",
      :address_key_path => "/ULRS311/Data/LIAddressKey/"
    }.merge(options)
  end

  def get_coordinates(address=nil)
    raise ArgumentError("Argument must be a string") unless address.is_a? String
    @coordinates_response ||= call_api('coordinates', address)
    parse_locations(@coordinates_response)
  end

  def get_address_key(address=nil)
    raise ArgumentError("Argument must be a string") unless address.is_a? String
    @address_key_response ||= call_api('address_key', address)
    JSON.parse(@address_key_response.body)
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

  def call_api(type, address)
    addr = URI::encode(address)
    type_path_map = {
      :coordinates => @settings[:location_path],
      :address_key => @settings[:address_key_path]
    }
    Net::HTTP.get_response(URI.parse("#{@settings[:api_base]}#{type_path_map[type.to_sym]}#{addr}"))
  end
end
