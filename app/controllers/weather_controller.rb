# frozen_string_literal: true

# WeatherController handles all weather-related web requests
# This controller provides endpoints for displaying weather information
# and handles both address-based and zip code-based weather lookups
#
# @example GET /weather
#   # Displays the weather search form
#
# @example GET /weather/show?address=New York, NY
#   # Shows weather for the specified address
#
# @example GET /weather/show?zip=10001
#   # Shows weather for the specified zip code (with caching)
#
class WeatherController < ApplicationController
  before_action :set_weather_service, only: [ :show ]
  before_action :validate_search_params, only: [ :show ]

  # Display the weather search form
  # This is the main landing page where users can enter an address or zip code
  def index
    # Initialize empty search form
    @search_query = params[:search_query] || ""
    @search_type = params[:search_type] || "address"
  end

  # Display weather information for the specified location
  # Handles both address and zip code searches with appropriate caching
  def show
    begin
      # Determine search type and get weather data
      if @search_type == "zip"
        @weather_data = @weather_service.get_weather_by_zip(@search_query)
      else
        @weather_data = @weather_service.get_weather_by_address(@search_query)
      end

      # Handle errors from the weather service
      if @weather_data[:error]
        flash.now[:alert] = @weather_data[:error]
        render :index, status: :unprocessable_entity
        return
      end

      # Set additional view variables
      @search_query = @search_query
      @search_type = @search_type
      @cached = @weather_data[:cached] || false
      @cache_timestamp = @weather_data[:cache_timestamp]

    rescue StandardError => e
      Rails.logger.error "Weather lookup failed: #{e.message}"
      flash.now[:alert] = "An unexpected error occurred while fetching weather data. Please try again."
      render :index, status: :internal_server_error
    end
  end

  private

  # Initialize the weather service with API key
  # Sets up the WeatherService instance for making API calls
  def set_weather_service
    @weather_service = WeatherService.new
  rescue ArgumentError => e
    Rails.logger.error "Weather service initialization failed: #{e.message}"
    flash.now[:alert] = "Weather service is not properly configured. Please contact support."
    render :index, status: :service_unavailable
  end

  # Validate search parameters
  # Ensures that required search parameters are present and valid
  def validate_search_params
    @search_query = params[:search_query]&.strip
    @search_type = params[:search_type] || "address"

    # Validate search query
    if @search_query.blank?
      flash.now[:alert] = "Please enter an address or zip code to search for weather information."
      render :index, status: :unprocessable_entity
      return
    end

    # Validate zip code format if searching by zip
    if @search_type == "zip" && !valid_zip_code?(@search_query)
      flash.now[:alert] = "Please enter a valid 5-digit zip code."
      render :index, status: :unprocessable_entity
      nil
    end
  end

  # Validate zip code format
  # @param zip_code [String] The zip code to validate
  # @return [Boolean] True if the zip code is valid
  def valid_zip_code?(zip_code)
    # US zip code format: 5 digits
    zip_code.match?(/\A\d{5}\z/)
  end
end
