module WeatherHelper
  # Convert wind direction degrees to compass direction text
  # @param degrees [Float] Wind direction in degrees (0-360)
  # @return [String] Compass direction (e.g., "N", "NE", "E", etc.)
  def wind_direction_text(degrees)
    return "N/A" if degrees.nil?

    # Normalize degrees to 0-360 range
    degrees = degrees % 360

    # Define compass directions and their degree ranges
    directions = [
      { name: "N", min: 348.75, max: 11.25 },
      { name: "NNE", min: 11.25, max: 33.75 },
      { name: "NE", min: 33.75, max: 56.25 },
      { name: "ENE", min: 56.25, max: 78.75 },
      { name: "E", min: 78.75, max: 101.25 },
      { name: "ESE", min: 101.25, max: 123.75 },
      { name: "SE", min: 123.75, max: 146.25 },
      { name: "SSE", min: 146.25, max: 168.75 },
      { name: "S", min: 168.75, max: 191.25 },
      { name: "SSW", min: 191.25, max: 213.75 },
      { name: "SW", min: 213.75, max: 236.25 },
      { name: "WSW", min: 236.25, max: 258.75 },
      { name: "W", min: 258.75, max: 281.25 },
      { name: "WNW", min: 281.25, max: 303.75 },
      { name: "NW", min: 303.75, max: 326.25 },
      { name: "NNW", min: 326.25, max: 348.75 }
    ]

    # Find the matching direction
    directions.find do |direction|
      if direction[:name] == "N"
        degrees >= direction[:min] || degrees <= direction[:max]
      else
        degrees >= direction[:min] && degrees < direction[:max]
      end
    end&.dig(:name) || "N"
  end
end
