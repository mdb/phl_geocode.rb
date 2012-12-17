require "json"
require "open-uri"
require "net/http"

class PHLGeocode
  attr_accessor :address_key_response
  attr_accessor :coordinates_response
  attr_accessor :last_queried_address_key_addr
  attr_accessor :last_queried_coordinates_addr
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

    if address == @last_queried_coordinates_addr
      @coordinates_response ||= call_api('coordinates', address)
    else
      @coordinates_response = call_api('coordinates', address)
      @last_queried_coordinates_addr = address
    end

    parse_locations @coordinates_response
  end

  def get_address_key(address=nil)
    raise ArgumentError("Argument must be a string") unless address.is_a? String

    if address == @last_queried_address_key_addr
      @address_key_response ||= call_api('address_key', address)
    else
      @address_key_response = call_api('address_key', address)
      @last_queried_address_key_addr = address
    end

    parse_address_key @address_key_response
  end

  private
  def parse_address_key(response)
    key_json = JSON.parse(response.body)
    
    {
      :agency_id => key_json["AgencyID"],
      :topic_name => key_json["TopicName"],
      :topic_id => key_json["TopicID"],
      :address_ref => key_json["AddressRef"]
    }
  end

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
