require 'rails_helper'

RSpec.describe WeatherHelper, type: :helper do
  describe '#wind_direction_text' do
    # Test data based on Apple HQ wind direction (301 degrees = WNW)
    let(:apple_hq_wind_direction) { 301 }

    it 'converts degrees to compass direction' do
      expect(helper.wind_direction_text(0)).to eq('N')
      expect(helper.wind_direction_text(90)).to eq('E')
      expect(helper.wind_direction_text(180)).to eq('S')
      expect(helper.wind_direction_text(270)).to eq('W')
    end

    it 'handles Apple HQ wind direction (WNW)' do
      expect(helper.wind_direction_text(apple_hq_wind_direction)).to eq('WNW')
    end

    it 'handles intermediate directions' do
      expect(helper.wind_direction_text(45)).to eq('NE')
      expect(helper.wind_direction_text(135)).to eq('SE')
      expect(helper.wind_direction_text(225)).to eq('SW')
      expect(helper.wind_direction_text(315)).to eq('NW')
    end

    it 'handles edge cases' do
      expect(helper.wind_direction_text(360)).to eq('N')
      expect(helper.wind_direction_text(720)).to eq('N') # 2 full rotations
      expect(helper.wind_direction_text(-90)).to eq('W') # negative degrees
    end

    it 'handles nil input' do
      expect(helper.wind_direction_text(nil)).to eq('N/A')
    end

    it 'handles fractional degrees' do
      expect(helper.wind_direction_text(301.5)).to eq('WNW')
      expect(helper.wind_direction_text(22.5)).to eq('NNE')
    end

    it 'handles all 16 compass directions' do
      directions = {
        0 => 'N', 22.5 => 'NNE', 45 => 'NE', 67.5 => 'ENE',
        90 => 'E', 112.5 => 'ESE', 135 => 'SE', 157.5 => 'SSE',
        180 => 'S', 202.5 => 'SSW', 225 => 'SW', 247.5 => 'WSW',
        270 => 'W', 292.5 => 'WNW', 315 => 'NW', 337.5 => 'NNW'
      }

      directions.each do |degrees, expected|
        expect(helper.wind_direction_text(degrees)).to eq(expected)
      end
    end
  end
end
