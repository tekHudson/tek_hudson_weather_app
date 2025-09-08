# Weather App

A Ruby on Rails application that provides current weather information for any address using coordinate-based lookups with ZIP code caching.

## Features

- 🌤️ **Current Weather Data** - Get real-time temperature, humidity, pressure, and wind information
- 📍 **Address Search with Autocomplete** - Search by full address with intelligent suggestions
- ⚡ **Smart ZIP Code Caching** - Results are cached by ZIP code for 30 minutes to improve performance
- 🎨 **Beautiful UI** - Responsive design with Bootstrap 5 and Font Awesome icons
- 🔄 **Cache Indicators** - Visual indicators show when data is retrieved from cache
- 🧪 **Comprehensive Tests** - Full RSpec test suite with WebMock for API testing

## Quick Start

### Prerequisites

- Ruby 3.3.1 (managed via rbenv)
- PostgreSQL
- WeatherAPI.com API key (free)

### Installation

1. **Clone and setup the project:**
   ```bash
   cd ~/ws/weather_app
   eval "$(rbenv init -)"
   bundle install
   ```

2. **Setup the database:**
   ```bash
   rails db:create
   rails db:migrate
   ```

3. **Get your WeatherAPI.com API key:**
   - Visit [WeatherAPI.com](https://www.weatherapi.com/signup.aspx)
   - Sign up for a free account
   - Get your API key from the dashboard

4. **Set your API key:**
   ```bash
   # Option 1: Environment variable
   export WEATHER_API_KEY='your_actual_api_key_here'
   
   # Option 2: Create .env file
   echo 'WEATHER_API_KEY=your_actual_api_key_here' > .env
   ```

5. **Start the server:**
   ```bash
   rails server
   ```

6. **Visit the application:**
   Open your browser to `http://localhost:3000`

## Usage

### Search by Address
- Enter a full address like "New York, NY" or "123 Main St, Boston, MA"
- The app will geocode the address and fetch weather data

### Search by Zip Code
- Enter a 5-digit US zip code like "10001" or "90210"
- Results are cached for 30 minutes for faster subsequent requests

### Cache Indicators
- Fresh data shows "Live Data" indicator
- Cached data shows "Cached Result" with timestamp

## API Integration

The app integrates with:
- **WeatherAPI.com** - For weather data and built-in geocoding
- **Rails Cache** - For 30-minute result caching

## Testing

Run the test suite:
```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/services/weather_service_spec.rb
bundle exec rspec spec/controllers/weather_controller_spec.rb
```

## Architecture

### Object Decomposition

#### WeatherService
- **Purpose**: Handles all weather API interactions and caching
- **Responsibilities**:
  - Fetching weather data from WeatherAPI.com (with built-in geocoding)
  - Managing 30-minute cache for addresses, zip codes, and coordinates
  - Parsing and formatting API responses
  - Error handling and logging

#### WeatherController
- **Purpose**: Handles web requests and user interactions
- **Responsibilities**:
  - Rendering search form and results
  - Validating user input (address/zip code)
  - Coordinating with WeatherService
  - Error handling and user feedback

#### Weather Views
- **Purpose**: Present weather data to users
- **Components**:
  - Search form with dynamic labels
  - Weather results display with icons
  - Cache indicators and timestamps
  - Responsive design for all devices

#### WeatherHelper
- **Purpose**: View helper methods
- **Responsibilities**:
  - Converting wind degrees to compass directions
  - Formatting weather data for display

## Configuration

### Environment Variables
- `WEATHER_API_KEY` - Required: Your WeatherAPI.com API key
- `RAILS_ENV` - Optional: Rails environment (defaults to development)

### Caching
- Results are cached for 30 minutes using Rails.cache
- Cache keys are based on zip codes or coordinates
- Cache timestamps are stored for display

## Error Handling

The application handles various error scenarios:
- Missing or invalid API keys
- Invalid addresses or zip codes
- API rate limits and errors
- Network connectivity issues
- Geocoding failures

## Development


### Code Quality
- Comprehensive documentation with YARD comments
- RSpec tests with WebMock for API stubbing
- RuboCop for code style consistency
- Error handling and logging throughout

## License

This project is built as a demonstration of Ruby on Rails best practices.

## Support

For issues or questions:
1. Check the error messages in the browser
2. Verify your API key is set correctly
3. Check the Rails logs for detailed error information
4. Ensure you have a stable internet connection
