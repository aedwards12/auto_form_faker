require 'spec_helper'

RSpec.describe AutoFormFaker::FormHelperExtension do
  let(:view) { MockActionView.new }

  before do
    stub_const('Rails', MockRails)
    Rails.env = 'development'
    allow(AutoFormFaker).to receive(:enabled?).and_return(true)
  end

  describe '#text_field' do
    it 'adds fake data when auto_faker is true' do
      allow(Faker::Name).to receive(:name).and_return('John Doe')
      
      result = view.text_field(:user, :name, auto_faker: true)
      
      expect(result).to include('value="John Doe"')
    end

    it 'uses specific faker class when auto_faker_class is provided' do
      result = view.text_field(:user, :name, auto_faker: true, auto_faker_class: 'Faker::Name.first_name')
      
      expect(result).to include('value=')
      expect(result).not_to include('auto_faker')
    end

    it 'uses specific ID when auto_faker is an integer' do
      result = view.text_field(:user, :user_id, auto_faker: 123)
      
      expect(result).to include('value="123"')
    end

    it 'does not add fake data when auto_faker is false' do
      result = view.text_field(:user, :name, auto_faker: false)
      
      expect(result).not_to include('value=')
    end

    it 'does not add fake data when AutoFormFaker is disabled' do
      allow(AutoFormFaker).to receive(:enabled?).and_return(false)
      
      result = view.text_field(:user, :name, auto_faker: true)
      
      expect(result).not_to include('value=')
    end

    it 'removes auto_faker options from final output' do
      result = view.text_field(:user, :name, auto_faker: true, auto_faker_class: 'Faker::Name.name')
      
      expect(result).not_to include('auto_faker')
      expect(result).not_to include('auto_faker_class')
    end
  end

  describe '#email_field' do
    it 'uses email faker by default' do
      allow(Faker::Internet).to receive(:email).and_return('test@example.com')
      
      result = view.email_field(:user, :email, auto_faker: true)
      
      expect(result).to include('value="test@example.com"')
    end
  end

  describe '#phone_field' do
    it 'uses phone number faker by default' do
      allow(Faker::PhoneNumber).to receive(:phone_number).and_return('555-1234')
      
      result = view.phone_field(:user, :phone, auto_faker: true)
      
      expect(result).to include('value="555-1234"')
    end
  end

  describe 'context-aware field detection' do
    it 'detects movie names' do
      allow(Faker::Movie).to receive(:title).and_return('The Dark Knight')
      
      result = view.text_field(:movie, :movie_name, auto_faker: true)
      
      expect(result).to include('value="The Dark Knight"')
    end

    it 'detects company names' do
      allow(Faker::Company).to receive(:name).and_return('Acme Corp')
      
      result = view.text_field(:business, :company_name, auto_faker: true)
      
      expect(result).to include('value="Acme Corp"')
    end

    it 'detects cities' do
      allow(Faker::Address).to receive(:city).and_return('New York')
      
      result = view.text_field(:address, :city, auto_faker: true)
      
      expect(result).to include('value="New York"')
    end
  end

  describe 'custom field mappings' do
    before do
      AutoFormFaker.configure do |config|
        config.field_mappings = {
          'superhero_name' => -> { 'Spider-Man' }
        }
      end
    end

    it 'uses custom mappings' do
      result = view.text_field(:hero, :superhero_name, auto_faker: true)
      
      expect(result).to include('value="Spider-Man"')
    end
  end
end