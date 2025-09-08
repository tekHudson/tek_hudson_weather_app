# frozen_string_literal: true

# WeatherController handles all weather-related web requests
# This controller provides endpoints for displaying weather information
# and handles coordinate-based weather lookups with ZIP code caching
#
# @example GET /weather
#   # Displays the weather search form
#
# @example GET /weather/show?lat=37.3313191&lng=-122.0103521&zip_code=94087&search_query=1%2C+Apple+Park+Way%2C+Cupertino%2C+California%2C+94087
#   # Shows weather for the specified coordinates, cached by ZIP code (94087)
#
class WeatherController < ApplicationController
  # Display the weather search form
  # This is the main landing page where users can enter an address
  def index
    # Initialize empty search form
    @search_query = params[:search_query] || ""
  end


  # Display weather information for the specified location
  def show
    return unless validate_search_params
    return unless set_weather_service

    begin
      # All searches now require lat/lng coordinates
      if params[:lat].present? && params[:lng].present?
        # Get ZIP code from parameter (extracted by frontend)
        zip_code = params[:zip_code]

        # Use coordinates for weather lookup but ZIP for caching
        @weather_data = @weather_service.get_weather_by_coordinates_with_zip_cache(
          params[:lat].to_f,
          params[:lng].to_f,
          zip_code
        )
      else
        # Handle invalid input - require coordinates
        flash.now[:alert] = "Please select an address from the suggestions to get weather information."
        render :index, status: :unprocessable_entity
        return
      end

      # Handle errors from the weather service
      if @weather_data[:error]
        flash.now[:alert] = @weather_data[:error]
        render :index, status: :unprocessable_entity
        return
      end

      # Set additional view variables
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
    false
  end

  # Validate search parameters
  # Ensures that required search parameters are present and valid
  def validate_search_params
    @search_query = params[:search_query]&.strip

    # Require search query, coordinates, and ZIP code
    if @search_query.blank? || params[:lat].blank? || params[:lng].blank? || params[:zip_code].blank?
      flash.now[:alert] = "Please select an address from the suggestions to get weather information."
      render :index, status: :unprocessable_entity
      return false
    end
    true
  end
end
