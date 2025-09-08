require 'rails_helper'

RSpec.describe 'weather/index', type: :view do
  # Apple Headquarters test data
  let(:apple_hq_address) { '1 Apple Park Way, Cupertino, CA' }

  before do
    assign(:search_query, apple_hq_address)
  end

  it 'renders the search form' do
    render

    expect(rendered).to include('form')
    expect(rendered).to include('action="/weather/show"')
    expect(rendered).to include('name="search_query"')
    expect(rendered).to include('type="submit"')
  end

  it 'displays the page title' do
    render

    expect(rendered).to include('Weather App')
    expect(rendered).to include('Get current weather information for any address')
  end

  it 'shows the search input with placeholder' do
    render

    expect(rendered).to include('placeholder="Enter address..."')
    expect(rendered).to include('value="1 Apple Park Way, Cupertino, CA"')
  end

  it 'displays feature cards' do
    render

    expect(rendered).to include('Current Temperature')
    expect(rendered).to include('High & Low Temps')
    expect(rendered).to include('Fast & Cached')
  end

  it 'includes required hidden fields for coordinates' do
    render

    expect(rendered).to include('name="lat"')
    expect(rendered).to include('name="lng"')
    expect(rendered).to include('name="zip_code"')
  end

  it 'has address suggestions dropdown' do
    render

    expect(rendered).to include('id="address-suggestions"')
    expect(rendered).to include('id="search_help"')
  end
end
