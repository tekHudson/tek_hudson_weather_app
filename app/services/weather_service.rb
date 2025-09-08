# frozen_string_literal: true

# WeatherService handles all weather-related API interactions
# This service provides a clean interface for fetching weather data from external APIs
# and includes built-in caching to improve performance and reduce API costs
#
# @example Basic usage
#   service = WeatherService.new
#   weather_data = service.get_weather_by_address("New York, NY")
#   puts weather_data[:current_temperature]
#
# @example With caching
#   # First call hits the API
#   weather_data = service.get_weather_by_address("10001")
#   # Second call within 30 minutes returns cached data
#   cached_weather = service.get_weather_by_address("10001")
#
class WeatherService
  include HTTParty

  # Base URL for WeatherAPI.com API
  BASE_URL = "https://api.weatherapi.com/v1"

  # Cache duration in seconds (30 minutes)
  CACHE_DURATION = 30.minutes

  # Initialize the weather service with API key
  # @param api_key [String] WeatherAPI.com API key
  def initialize(api_key = nil)
    @api_key = api_key || ENV["WEATHER_API_KEY"]
    if @api_key.blank? || @api_key == "your_api_key_here"
      raise ArgumentError, "WeatherAPI.com API key is required. Please set WEATHER_API_KEY environment variable or get a free API key at https://www.weatherapi.com/signup.aspx"
    end
  end

  # Get weather data for a given address
  # This method uses WeatherAPI.com's built-in geocoding
  # @param address [String] The address to get weather for
  # @return [Hash] Weather data including current temperature, high/low, and extended forecast
  def get_weather_by_address(address)
    return { error: "Address cannot be blank" } if address.blank?

    # Use address as cache key
    cache_key = "weather_address_#{address.downcase.gsub(/\s+/, '_')}"

    # Try to get from cache first
    cached_data = Rails.cache.read(cache_key)
    if cached_data
      cached_data[:cached] = true
      cached_data[:cache_timestamp] = Rails.cache.read("#{cache_key}_timestamp")
      return cached_data
    end

    # If not in cache, fetch from API
    weather_data = fetch_weather_data(address: address)

    # Cache the result for 30 minutes
    if weather_data[:error].nil?
      Rails.cache.write(cache_key, weather_data, expires_in: CACHE_DURATION)
      Rails.cache.write("#{cache_key}_timestamp", Time.current, expires_in: CACHE_DURATION)
      weather_data[:cached] = false
    end

    weather_data
  end

  # Get weather data for a given zip code
  # This method uses caching to avoid repeated API calls for the same zip code
  # @param zip_code [String] The zip code to get weather for
  # @return [Hash] Weather data including current temperature, high/low, and extended forecast
  def get_weather_by_zip(zip_code)
    return { error: "Zip code cannot be blank" } if zip_code.blank?

    # Use zip code as cache key
    cache_key = "weather_zip_#{zip_code}"

    # Try to get from cache first
    cached_data = Rails.cache.read(cache_key)
    if cached_data
      cached_data[:cached] = true
      cached_data[:cache_timestamp] = Rails.cache.read("#{cache_key}_timestamp")
      return cached_data
    end

    # If not in cache, fetch from API with multiple zip code formats
    weather_data = fetch_weather_data_for_zip(zip_code)

    # Cache the result for 30 minutes
    if weather_data[:error].nil?
      Rails.cache.write(cache_key, weather_data, expires_in: CACHE_DURATION)
      Rails.cache.write("#{cache_key}_timestamp", Time.current, expires_in: CACHE_DURATION)
      weather_data[:cached] = false
    end

    weather_data
  end

  # Get weather data using latitude and longitude coordinates
  # @param lat [Float] Latitude
  # @param lng [Float] Longitude
  # @return [Hash] Weather data
  def get_weather_by_coordinates(lat, lng)
    # Use coordinates as cache key
    cache_key = "weather_coords_#{lat.round(4)}_#{lng.round(4)}"

    # Try to get from cache first
    cached_data = Rails.cache.read(cache_key)
    if cached_data
      cached_data[:cached] = true
      cached_data[:cache_timestamp] = Rails.cache.read("#{cache_key}_timestamp")
      return cached_data
    end

    # If not in cache, fetch from API
    weather_data = fetch_weather_data(lat: lat, lng: lng)

    # Cache the result for 30 minutes
    if weather_data[:error].nil?
      Rails.cache.write(cache_key, weather_data, expires_in: CACHE_DURATION)
      Rails.cache.write("#{cache_key}_timestamp", Time.current, expires_in: CACHE_DURATION)
      weather_data[:cached] = false
    end

    weather_data
  end

  private

  # Fetch weather data for zip code with multiple format attempts
  # @param zip_code [String] The zip code to get weather for
  # @return [Hash] Weather data or error information
  def fetch_weather_data_for_zip(zip_code)
    # Try different zip code formats to ensure we get the correct US location
    zip_formats = [
      zip_code,                    # Just the zip code
      "#{zip_code}, USA",         # Zip code with USA
      "#{zip_code}, US",          # Zip code with US
      "#{zip_code}, United States" # Zip code with full country name
    ]

    zip_formats.each_with_index do |format, index|
      Rails.logger.info "Trying zip format #{index + 1}: #{format}"

      weather_data = fetch_weather_data(zip_code: format)

      # If we got a successful response, check if it's actually in the US
      if weather_data[:error].nil? && weather_data[:location]
        country = weather_data[:location][:country]
        Rails.logger.info "Got response for country: #{country}"

        # If it's the US, return the data immediately
        if country&.include?("USA") || country&.include?("United States")
          Rails.logger.info "Successfully found US location for zip #{zip_code} using format: #{format}"
          return weather_data
        else
          Rails.logger.warn "Zip #{zip_code} returned location in #{country}, trying next format"
        end
      else
        Rails.logger.warn "Zip format #{format} returned error: #{weather_data[:error]}"
      end
    end

    # If none of the formats worked, return the last error
    { error: "Could not find weather data for zip code #{zip_code} in the United States" }
  end


  # Fetch weather data from the WeatherAPI.com API
  # @param options [Hash] Options for the API call
  # @option options [String] :zip_code Zip code for weather lookup
  # @option options [Float] :lat Latitude for weather lookup
  # @option options [Float] :lng Longitude for weather lookup
  # @option options [String] :address Address for weather lookup
  # @return [Hash] Weather data or error information
  def fetch_weather_data(options = {})
    begin
      # Build the API endpoint and query parameters
      endpoint = "#{BASE_URL}/current.json"

      # Determine the location parameter based on available options
      location = if options[:zip_code]
                   # Try different formats for zip codes to ensure correct location
                   zip_code = options[:zip_code]
                   # First try with just the zip code
                   zip_code
      elsif options[:lat] && options[:lng]
                   "#{options[:lat]},#{options[:lng]}"
      elsif options[:address]
                   options[:address]
      else
                   return { error: "Invalid parameters for weather lookup" }
      end

      params = {
        key: @api_key,
        q: location,
        aqi: "no" # We don't need air quality data for this app
      }

      # Log the request for debugging
      Rails.logger.info "WeatherAPI request: #{endpoint} with params: #{params}"

      # Make the API request
      response = self.class.get(endpoint, query: params)

      # Log the response for debugging
      Rails.logger.info "WeatherAPI response: #{response.code} - #{response.parsed_response}"

      # Handle API errors
      unless response.success?
        error_message = case response.code
        when 400
                          "Bad request - invalid location or parameters"
        when 401
                          "Invalid API key"
        when 403
                          "API access forbidden - check your subscription"
        when 404
                          "Weather data not found for this location"
        when 429
                          "API rate limit exceeded"
        else
                          "API error: #{response.code}"
        end
        return { error: error_message }
      end

      # Parse and format the response
      parse_weather_response(response.parsed_response)

    rescue StandardError => e
      Rails.logger.error "Weather API request failed: #{e.message}"
      { error: "Failed to fetch weather data" }
    end
  end

  # Parse the WeatherAPI.com API response into a standardized format
  # @param api_response [Hash] Raw API response
  # @return [Hash] Formatted weather data
  def parse_weather_response(api_response)
    {
      location: {
        name: api_response["location"]["name"],
        country: api_response["location"]["country"],
        coordinates: {
          lat: api_response["location"]["lat"],
          lng: api_response["location"]["lon"]
        }
      },
      current_weather: {
        temperature: api_response["current"]["temp_f"].round(1),
        feels_like: api_response["current"]["feelslike_f"].round(1),
        humidity: api_response["current"]["humidity"],
        pressure: api_response["current"]["pressure_in"],
        description: api_response["current"]["condition"]["text"],
        icon: api_response["current"]["condition"]["icon"]
      },
      temperature_range: {
        high: api_response["current"]["temp_f"].round(1), # WeatherAPI.com doesn't provide daily high/low in current endpoint
        low: api_response["current"]["temp_f"].round(1)   # We'll use current temp for both for now
      },
      wind: {
        speed: api_response["current"]["wind_mph"],
        direction: api_response["current"]["wind_degree"]
      },
      visibility: api_response["current"]["vis_miles"],
      timestamp: Time.parse(api_response["current"]["last_updated"]),
      fetched_at: Time.current
    }
  end
end
