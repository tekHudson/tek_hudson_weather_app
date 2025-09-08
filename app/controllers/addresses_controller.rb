# frozen_string_literal: true

# AddressesController handles address autocomplete functionality
# This controller is responsible for providing address suggestions
# using the Nominatim geocoding service
class AddressesController < ApplicationController
  # Autocomplete addresses using Nominatim geocoding service
  # Returns JSON array of address suggestions, prioritized by street addresses
  # @return [JSON] Array of address suggestions with coordinates
  def autocomplete
    query = params[:q]
    return render json: [] if query.blank? || query.length < 3

    begin
      # Use Nominatim for free address autocomplete
      response = HTTParty.get("https://nominatim.openstreetmap.org/search", {
        query: {
          q: query,
          format: "json",
          limit: 100, # Get more results to allow for better sorting
          countrycodes: "us", # Limit to US addresses
          addressdetails: 1
        },
        headers: {
          "User-Agent" => "WeatherApp/1.0"
        }
      })

      if response.success?
        addresses = response.parsed_response.map do |result|
          address_data = result["address"]
          {
            display_name: result["display_name"],
            lat: result["lat"],
            lon: result["lon"],
            formatted_address: format_address(address_data),
            address_data: address_data,
            priority_score: calculate_priority_score(address_data, query)
          }
        end

        # Sort by priority score (higher is better) and take top 5
        sorted_addresses = addresses.sort_by { |addr| -addr[:priority_score] }.first(5)

        # Remove the priority_score from the final response
        final_addresses = sorted_addresses.map { |addr| addr.except(:address_data, :priority_score) }

        render json: final_addresses
      else
        render json: []
      end
    rescue StandardError => e
      Rails.logger.error "Address autocomplete failed: #{e.message}"
      render json: []
    end
  end

  private

  # Calculate priority score for address sorting
  # Prioritizes street addresses over cities, landmarks, etc.
  # @param address [Hash] Address details from Nominatim
  # @param query [String] The search query
  # @return [Integer] Priority score (higher is better)
  def calculate_priority_score(address, query)
    score = 0

    # Highest priority: Has house number (actual street address)
    score += 100 if address["house_number"].present?

    # High priority: Has road/street name
    score += 50 if address["road"].present?

    # Medium priority: Has city (check multiple possible field names)
    city = address["city"] || address["town"] || address["village"] || address["hamlet"]
    score += 25 if city.present?

    # Lower priority: Has state
    score += 10 if address["state"].present?

    # Bonus for exact matches in key fields
    query_lower = query.downcase

    # Bonus for house number match
    if address["house_number"]&.downcase&.include?(query_lower)
      score += 30
    end

    # Bonus for road name match
    if address["road"]&.downcase&.include?(query_lower)
      score += 20
    end

    # Bonus for city match (check multiple possible field names)
    city = address["city"] || address["town"] || address["village"] || address["hamlet"]
    if city&.downcase&.include?(query_lower)
      score += 15
    end

    # Penalty for being too generic (no specific address)
    if address["house_number"].blank? && address["road"].blank?
      score -= 25
    end

    # Penalty for being a landmark or POI instead of residential address
    if address["amenity"].present? || address["tourism"].present? || address["shop"].present?
      score -= 15
    end

    score
  end

  # Format address from Nominatim response
  # @param address [Hash] Address details from Nominatim
  # @return [String] Formatted address string
  def format_address(address)
    parts = []
    parts << address["house_number"] if address["house_number"]
    parts << address["road"] if address["road"]

    # Handle different city field names that Nominatim might use
    city = address["city"] || address["town"] || address["village"] || address["hamlet"]
    parts << city if city.present?

    # Handle different state field names
    state = address["state"] || address["province"] || address["region"]
    parts << state if state.present?

    parts << address["postcode"] if address["postcode"]
    parts.join(", ")
  end
end
