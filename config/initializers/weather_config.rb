# frozen_string_literal: true

# Weather App Configuration
# This file contains configuration settings for the weather application

# WeatherAPI.com API Configuration
# Set your API key as an environment variable: WEATHER_API_KEY
# You can get a free API key at: https://www.weatherapi.com/signup.aspx
Rails.application.configure do
  # Weather service configuration
  config.weather = ActiveSupport::OrderedOptions.new

  # API key for WeatherAPI.com
  config.weather.api_key = ENV["WEATHER_API_KEY"]

  # Cache configuration
  config.weather.cache_duration = 30.minutes

  # Default units (imperial for Fahrenheit, metric for Celsius)
  config.weather.units = "imperial"

  # API base URL
  config.weather.api_base_url = "https://api.weatherapi.com/v1"
end

# Validate required configuration
if Rails.env.production? && ENV["WEATHER_API_KEY"].blank?
  Rails.logger.warn "WEATHER_API_KEY environment variable is not set. Weather functionality will not work."
end
