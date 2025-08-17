require 'spec_helper'

RSpec.describe AutoFormFaker do
  describe '.enabled?' do
    before do
      stub_const('Rails', MockRails)
    end

    it 'is enabled in development environment' do
      Rails.env = 'development'
      expect(AutoFormFaker.enabled?).to be true
    end

    it 'is enabled in staging environment' do
      Rails.env = 'staging'
      expect(AutoFormFaker.enabled?).to be true
    end

    it 'is disabled in production environment' do
      Rails.env = 'production'
      expect(AutoFormFaker.enabled?).to be false
    end

    it 'is disabled in test environment by default' do
      Rails.env = 'test'
      expect(AutoFormFaker.enabled?).to be false
    end
  end

  describe '.configure' do
    it 'allows customizing enabled environments' do
      AutoFormFaker.configure do |config|
        config.enabled_environments = [:test]
      end

      expect(AutoFormFaker.configuration.enabled_environments).to eq([:test])
    end

    it 'allows custom field mappings' do
      AutoFormFaker.configure do |config|
        config.field_mappings = {
          'custom_field' => -> { 'custom_value' }
        }
      end

      expect(AutoFormFaker.configuration.field_mappings['custom_field'].call).to eq('custom_value')
    end
  end
end