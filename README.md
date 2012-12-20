[![Build Status](https://secure.travis-ci.org/mdb/phl_geocode.rb.png?branch=master)](https://travis-ci.org/mdb/phl_geocode.rb)

# phl_geocode

A Ruby gem for getting latitude and longitude coordinates for a Philadelphia address.

This is the Ruby version of the Node.js [phl-geocode](http://github.com/mdb/phl-geocode).

The gem uses Philadelphia's [311 Mobile Data Service API](http://services.phila.gov/ULRS311).

## Get lat/long coordinates for a Philadelphia Address:

    require "phl_geocode"
    phl = PHLGeocode.new
    phl.get_coordinates "1500 Market Street"

Example response:
    
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

## Get the address key for a Philadelphia Address:

    require "phl_geocode"
    phl = PHLGeocode.new
    phl.get_address_key "1500 Market Street"

Example response:

    {
      :agency_id => "26",
      :topic_name => "AddressKeys",
      :topic_id => "410526",
      :address_ref => "01500 MARKET ST"
    }

## Override default settings:

    require "phl_geocode"
    phl = PHLGeocode.new :min_confidence => 100
    phl.get_coordinates "1500 Market Street"
