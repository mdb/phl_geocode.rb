require "spec_helper"

describe PHLGeocode do
  before :each do
    phl_geocode_root = File.expand_path(File.dirname(File.dirname(File.dirname(__FILE__))))
    fake_resp_body_file = File.join(phl_geocode_root, "spec", "fixtures", "fake_http_response_body.json")
    @fake_http_response_body = File.open(fake_resp_body_file).read
  end

  describe "#new" do
    before :each do
      @phl = PHLGeocode.new
    end

    it "creates a new PHLGeocode instance" do 
      @phl.class.should == PHLGeocode
    end

    context "it is not passed any options" do
      it "creates a :settings hash with some default settings" do
        @phl.settings[:min_confidence].should eq 85
        @phl.settings[:api_base].should eq "http://services.phila.gov"
        @phl.settings[:location_path].should eq "/ULRS311/Data/Location/"
        @phl.settings[:address_key_path].should eq "/ULRS311/Data/LIAddressKey/"
      end
    end

    context "it is passed options on instantiation" do
      it "has a settings hash set to the value of the options its passed" do
        phl = PHLGeocode.new :min_confidence => 100
        phl.settings[:min_confidence].should == 100
      end

      it "preserves default settings if no overriding values are passed in the options" do
        phl = PHLGeocode.new :foo => "bar"
        phl.settings[:min_confidence].should == 85
        phl.settings[:foo].should == "bar"
      end
    end
  end

  describe "#get_coordinates" do
    before :each do
      @phl = PHLGeocode.new
      @http_mock = mock("Net::HTTP")
      @http_mock.stubs(
        :code => 200,
        :message => "OK",
        :content_type => "application/json",
        :body => @fake_http_response_body
      )
      Net::HTTP.stub(:get_response).and_return @http_mock 
    end

    it "exists as a method on a PHLGeocode" do
      @phl.respond_to?(:get_coordinates).should == true
    end

    it "raises an error if it is not passed a valid string argument" do
      lambda { @phl.get_coordinates }.should raise_error
      lambda { @phl.get_coordinates(3) }.should raise_error
      lambda { @phl.get_coordinates(nil) }.should raise_error
      lambda { @phl.get_coordinates({}) }.should raise_error
    end

    context "it is passed an address for the first time" do
      it "makes a properly formatted API call to the proper endpoint" do
        Net::HTTP.should_receive(:get_response).with(URI.parse("http://services.phila.gov/ULRS311/Data/Location/some%20address"))
        @phl.get_coordinates "some address"
      end

      it "sets :coordinates_response to the value of the API call response" do
        @phl.get_coordinates "some address"
        @phl.coordinates_response.should == @http_mock
      end

      it "returns an array of locations whose :similarity is greater than or equal to :settings.min_confidence" do
        @phl.get_coordinates("some address")[0][:similarity].should == 100
      end

      it "returns an array of locations, each of which reports a :latitude" do
        @phl.get_coordinates("some address")[0][:latitude].should == 39.9521740263203
      end

      it "returns an array of locations, each of which reports a :longitude" do
        @phl.get_coordinates("some address")[0][:longitude].should == -75.1661518986459
      end

      it "returns an array of locations, each of which reports a standardized address as :address" do
        @phl.get_coordinates("some address")[0][:address].should == "FAKE ADDRESS"
      end
    end

    context "it is passed the address it was last passed" do
      before :each do
        @phl.get_coordinates "some address 1"
      end

      it "does not make a properly formatted API call to the proper endpoint" do
        Net::HTTP.should_not_receive(:get_response).with(URI.parse("http://services.phila.gov/ULRS311/Data/Location/some%20address%201"))
        @phl.get_coordinates "some address 1"
      end

    end
  end

  describe "#get_address_key" do
    before :each do
      @phl = PHLGeocode.new
      @http_mock = mock("Net::HTTP")
      @http_mock.stubs(
        :code => 200,
        :message => "OK",
        :content_type => "application/json",
        :body => {foo: "bar"}.to_json
      )
      Net::HTTP.stub(:get_response).and_return @http_mock 
    end

    it "exists as a method on a PHLGeocode" do
      @phl.respond_to?(:get_address_key).should eq true
    end

    it "raises an error if it is not passed a valid string argument" do
      lambda { @phl.get_address_key }.should raise_error
      lambda { @phl.get_address_key(3) }.should raise_error
      lambda { @phl.get_address_key(nil) }.should raise_error
      lambda { @phl.get_address_key({}) }.should raise_error
    end

    context "it is passed an address for the first time" do
      it "makes a properly formatted API call to the proper endpoint" do
        Net::HTTP.should_receive(:get_response).with(URI.parse("http://services.phila.gov/ULRS311/Data/LIAddressKey/some%20address"))
        @phl.get_address_key "some address"
      end

      it "sets :address_key_response to the value of the API call response" do
        @phl.get_address_key "some address"
        @phl.address_key_response.should == @http_mock
      end

      it "sets :last_queried_address_key_addr to the value of the address it is passed" do
        @phl.get_address_key "some address 1"
        @phl.last_queried_address_key_addr.should == "some address 1"
      end
    end

    context "it is passed the same address it was last passed" do
      before :each do
        @phl.get_address_key "some address a"
      end

      it "does not makes a properly formatted API call to the proper endpoint" do
        Net::HTTP.should_not_receive(:get_response).with(URI.parse("http://services.phila.gov/ULRS311/Data/LIAddressKey/some%20address%20a"))
        @phl.get_address_key "some address a"
      end
    end
  end
end
