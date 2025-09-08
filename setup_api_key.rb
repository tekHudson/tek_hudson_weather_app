#!/usr/bin/env ruby
# frozen_string_literal: true

# Setup script for Weather App API Key
# This script helps you set up the WeatherAPI.com API key

puts "🌤️  Weather App Setup"
puts "=" * 50
puts
puts "To use this weather application, you need a free WeatherAPI.com API key."
puts
puts "Steps to get your API key:"
puts "1. Visit: https://www.weatherapi.com/signup.aspx"
puts "2. Click 'Sign Up' to create a free account"
puts "3. Verify your email address"
puts "4. Go to your dashboard at https://www.weatherapi.com/my/"
puts "5. Copy your API key"
puts
puts "Once you have your API key, you can set it in one of these ways:"
puts
puts "Option 1 - Set environment variable:"
puts "  export WEATHER_API_KEY='your_actual_api_key_here'"
puts
puts "Option 2 - Edit the .env file:"
puts "  echo 'WEATHER_API_KEY=your_actual_api_key_here' > .env"
puts
puts "Option 3 - Set it when starting the server:"
puts "  WEATHER_API_KEY=your_actual_api_key_here rails server"
puts
puts "After setting the API key, restart your Rails server and try the weather search again!"
puts
puts "WeatherAPI.com Features:"
puts "- 1 million free API calls per month"
puts "- Built-in geocoding (no need for separate geocoding service)"
puts "- Real-time weather data"
puts "- No credit card required for free tier"
