require 'rails_helper'

RSpec.describe 'weather/show', type: :view do
  # Apple Headquarters test data
  let(:apple_hq_weather_data) do
    {
      location: {
        name: 'Cupertino',
        region: 'California',
        country: 'United States of America',
        coordinates: { lat: 37.323, lng: -122.031 }
      },
      current_weather: {
        temperature: 72.1,
        feels_like: 76.4,
        humidity: 69,
        pressure: 30.09,
        description: 'Partly cloudy',
        icon: '//cdn.weatherapi.com/weather/64x64/day/116.png'
      },
      temperature_range: {
        high: 72.1,
        low: 72.1
      },
      wind: {
        speed: 2.2,
        direction: 301
      },
      visibility: 9.0,
      timestamp: Time.parse('2025-09-08 11:30'),
      fetched_at: Time.current
    }
  end

  before do
    assign(:weather_data, apple_hq_weather_data)
    assign(:cached, false)
    assign(:cache_timestamp, nil)
  end

  it 'renders weather information' do
    render

    expect(rendered).to include('Cupertino')
    expect(rendered).to include('72.1°F')
    expect(rendered).to include('Partly cloudy')
  end

  it 'displays temperature details' do
    render

    expect(rendered).to include('72.1°F')
    expect(rendered).to include('Feels like 76.4°F')
    expect(rendered).to include('High')
    expect(rendered).to include('Low')
  end

  it 'shows weather metrics' do
    render

    expect(rendered).to include('69%') # Humidity
    expect(rendered).to include('30.09 hPa') # Pressure
    expect(rendered).to include('2.2 mph') # Wind Speed
    expect(rendered).to include('0.0 km') # Visibility (converted from miles)
  end

  it 'displays wind direction' do
    render

    expect(rendered).to include('Wind Direction')
    expect(rendered).to include('301°')
    expect(rendered).to include('WNW')
  end

  it 'shows back button' do
    render

    expect(rendered).to include('Back to Search')
    expect(rendered).to include('href="/"')
  end

  it 'shows search again section' do
    render

    expect(rendered).to include('Search Another Location')
    expect(rendered).to include('Search Again')
  end

  context 'when data is cached' do
    before do
      assign(:cached, true)
      assign(:cache_timestamp, 30.minutes.ago)
    end

    it 'displays cache indicator' do
      render

      expect(rendered).to include('Cached Result')
      expect(rendered).to include('Originally fetched at')
    end
  end

  context 'when data is not cached' do
    it 'does not display cache indicator' do
      render

      expect(rendered).not_to include('Cached Result')
    end
  end
end
