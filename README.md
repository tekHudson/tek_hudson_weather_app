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

## Known issues
Entering and selecting a city and state doesnt work due to zip code dependence.
* Best solution would be to accept these types of requests and reverse look up a ZIP Code, but that with someone invalidate the logic of Cashin by ZIP Code, but there could be many ZIP Codes in a single city.
