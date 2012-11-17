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
        @phl.settings[:min_confidence].should == 81
        @phl.settings[:api_base].should == "http://services.phila.gov/ULRS311/Data/Location/"
      end
    end

    context "it is passed options on instantiation" do
      it "has a settings hash set to the value of the options its passed" do
        phl = PHLGeocode.new :min_confidence => 100
        phl.settings[:min_confidence].should == 100
      end

      it "preserves default settings if no overriding values are passed in the options" do
        phl = PHLGeocode.new :foo => "bar"
        phl.settings[:min_confidence].should == 81 
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
      Net::HTTP.stubs(:get_response).returns(@http_mock)
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

    it "sets :response to the value of the API call response" do
      @phl.get_coordinates "some address"
      @phl.response.should == @http_mock
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
end
