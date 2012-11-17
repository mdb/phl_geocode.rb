# phl_geocode

A Ruby gem for getting latitude and longitude coordinates for a Philadelphia address.

This is the Ruby version of the Node.js [phl-geocoder](http://github.com/mdb/phl-geocoder).

The gem uses Philadelphia's [311 Mobile Data Service API](http://services.phila.gov/ULRS311).

## Example Usage

    require "phl_geocode"
    phl = PHLGeocode.new
    phl.get_coordinates "1500 Market Street"

## Example Response
    
    [{
      :address => "1500 MARKET ST",
      :similarity => 100,
      :latitude => 39.9521740263203,
      :longitude => -75.1661518986459
    }, {
      :address => "1500S MARKET ST",
      :similarity => 99,
      :latitude => 39.9521740263203,
      :longitude => -75.1661518986459
    }]
