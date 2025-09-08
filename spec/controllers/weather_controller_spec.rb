require 'rails_helper'

RSpec.describe WeatherController, type: :controller do
  # Apple Headquarters test data
  let(:apple_hq_lat) { 37.3302709 }
  let(:apple_hq_lng) { -122.0079753 }
  let(:apple_hq_zip) { '94087' }
  let(:apple_hq_address) { '1 Apple Park Way, Cupertino, CA' }

  let(:weather_service) { instance_double(WeatherService) }
  let(:valid_weather_data) do
    {
      location: {
        name: 'Cupertino',
        region: 'California',
        country: 'United States of America',
        coordinates: { lat: 37.323, lng: -122.031 }
      },
      current_weather: {
        temperature: 72.1,
        description: 'Partly cloudy',
        humidity: 69,
        pressure: 30.09
      },
      wind: { speed: 2.2, direction: 301 },
      visibility: 9.0,
      cached: false
    }
  end

  before do
    allow(WeatherService).to receive(:new).and_return(weather_service)
  end

  describe 'GET #index' do
    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'sets default search query' do
      get :index
      expect(assigns(:search_query)).to eq('')
    end

    it 'preserves search query from params' do
      get :index, params: { search_query: apple_hq_address }
      expect(assigns(:search_query)).to eq(apple_hq_address)
    end
  end

  describe 'GET #show' do
    context 'with valid coordinates from typeahead' do
      before do
        allow(weather_service).to receive(:get_weather_by_coordinates_with_zip_cache)
          .with(apple_hq_lat, apple_hq_lng, apple_hq_zip)
          .and_return(valid_weather_data)
      end

      it 'uses coordinates for weather lookup' do
        get :show, params: {
          search_query: apple_hq_address,
          lat: apple_hq_lat,
          lng: apple_hq_lng,
          zip_code: apple_hq_zip
        }

        expect(weather_service).to have_received(:get_weather_by_coordinates_with_zip_cache)
          .with(apple_hq_lat, apple_hq_lng, apple_hq_zip)
      end

      it 'renders show template with weather data' do
        get :show, params: {
          search_query: apple_hq_address,
          lat: apple_hq_lat,
          lng: apple_hq_lng,
          zip_code: apple_hq_zip
        }

        expect(response).to render_template(:show)
        expect(assigns(:weather_data)).to eq(valid_weather_data)
      end
    end

    context 'with missing coordinates' do
      it 'redirects to index with error' do
        get :show, params: { search_query: apple_hq_address }

        expect(response).to render_template(:index)
        expect(response.status).to eq(422)
        expect(flash.now[:alert]).to include('Please select an address from the suggestions')
      end
    end

    context 'with weather service error' do
      before do
        allow(weather_service).to receive(:get_weather_by_coordinates_with_zip_cache)
          .and_return({ error: 'Weather service unavailable' })
      end

      it 'handles weather service errors' do
        get :show, params: {
          search_query: apple_hq_address,
          lat: apple_hq_lat,
          lng: apple_hq_lng,
          zip_code: apple_hq_zip
        }

        expect(response).to render_template(:index)
        expect(response.status).to eq(422)
        expect(flash.now[:alert]).to eq('Weather service unavailable')
      end
    end

    context 'with API key error' do
      before do
        allow(WeatherService).to receive(:new)
          .and_raise(ArgumentError.new('API key required'))
      end

      it 'handles API key errors' do
        get :show, params: {
          search_query: apple_hq_address,
          lat: apple_hq_lat,
          lng: apple_hq_lng,
          zip_code: apple_hq_zip
        }

        expect(response).to render_template(:index)
        expect(response.status).to eq(503)
        expect(flash.now[:alert]).to include('Weather service is not properly configured')
      end
    end
  end
end
