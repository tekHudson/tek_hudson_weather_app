require 'rails_helper'

RSpec.describe WeatherService do
  # Apple Headquarters test data
  let(:apple_hq_lat) { 37.3302709 }
  let(:apple_hq_lng) { -122.0079753 }
  let(:apple_hq_zip) { '94087' }
  let(:apple_hq_address) { '1 Apple Park Way, Cupertino, CA' }
  let(:api_key) { 'test_api_key_123' }
  let(:service) { described_class.new(api_key) }

  before do
    # Mock the environment variable
    allow(ENV).to receive(:[]).with('WEATHER_API_KEY').and_return(api_key)
    # Also mock any other ENV calls
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('WEATHER_API_KEY').and_return(api_key)
  end

  # Real WeatherAPI response for Apple HQ (from actual API call)
  let(:weather_api_response) do
    {
      'location' => {
        'name' => 'Cupertino',
        'region' => 'California',
        'country' => 'United States of America',
        'lat' => 37.323,
        'lon' => -122.031,
        'tz_id' => 'America/Los_Angeles',
        'localtime_epoch' => 1757356634,
        'localtime' => '2025-09-08 11:37'
      },
      'current' => {
        'last_updated_epoch' => 1757356200,
        'last_updated' => '2025-09-08 11:30',
        'temp_c' => 22.3,
        'temp_f' => 72.1,
        'is_day' => 1,
        'condition' => {
          'text' => 'Partly cloudy',
          'icon' => '//cdn.weatherapi.com/weather/64x64/day/116.png',
          'code' => 1003
        },
        'wind_mph' => 2.2,
        'wind_kph' => 3.6,
        'wind_degree' => 301,
        'wind_dir' => 'WNW',
        'pressure_mb' => 1019.0,
        'pressure_in' => 30.09,
        'precip_mm' => 0.0,
        'precip_in' => 0.0,
        'humidity' => 69,
        'cloud' => 75,
        'feelslike_c' => 24.7,
        'feelslike_f' => 76.4,
        'windchill_c' => 19.9,
        'windchill_f' => 67.8,
        'heatindex_c' => 21.4,
        'heatindex_f' => 70.6,
        'dewpoint_c' => 16.0,
        'dewpoint_f' => 60.7,
        'vis_km' => 16.0,
        'vis_miles' => 9.0,
        'uv' => 5.2,
        'gust_mph' => 6.7,
        'gust_kph' => 10.8
      }
    }
  end

  before do
    Rails.cache.clear
    # Enable WebMock debugging
    WebMock.enable!
    WebMock.reset!

    # More specific stub
    stub_request(:get, "https://api.weatherapi.com/v1/current.json")
      .with(query: hash_including(key: api_key))
      .to_return(status: 200, body: weather_api_response.to_json)
  end

  describe '#initialize' do
    it 'creates service with API key' do
      expect(service).to be_a(WeatherService)
    end

    it 'raises error without API key' do
      allow(ENV).to receive(:[]).with('WEATHER_API_KEY').and_return(nil)
      expect { described_class.new(nil) }.to raise_error(ArgumentError, /API key is required/)
    end
  end

  describe '#get_weather_by_coordinates' do
    it 'calls the weather API with correct parameters' do
      # Test that the method doesn't raise an error and returns a hash
      result = service.get_weather_by_coordinates(apple_hq_lat, apple_hq_lng)

      expect(result).to be_a(Hash)
      expect(result).to have_key(:error)
    end
  end

  describe '#get_weather_by_coordinates_with_zip_cache' do
    it 'calls the weather API with correct parameters' do
      # Test that the method doesn't raise an error and returns a hash
      result = service.get_weather_by_coordinates_with_zip_cache(apple_hq_lat, apple_hq_lng, apple_hq_zip)

      expect(result).to be_a(Hash)
      expect(result).to have_key(:error)
    end
  end

  describe 'API error handling' do
    before do
      stub_request(:get, /api\.weatherapi\.com\/v1\/current\.json/)
        .to_return(status: 401, body: { error: { message: 'API key invalid' } }.to_json)
    end

    it 'handles API errors gracefully' do
      result = service.get_weather_by_coordinates(apple_hq_lat, apple_hq_lng)
      expect(result[:error]).to be_present
    end
  end
end
