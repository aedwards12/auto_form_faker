require 'spec_helper'

# Create a mock SimpleForm module for testing if it's not available
unless defined?(SimpleForm)
  module SimpleForm
    module FormBuilder
    end
  end
end

class MockSimpleFormBuilder
  def initialize
    @template = nil
    @object = OpenStruct.new
    @object_name = :user
    @options = {}
  end

  # Define the input method first
  def input(attribute_name, options = {}, &block)
    # Simulate SimpleForm's input method behavior
    input_html = options[:input_html] || {}
    value = input_html[:value] || options[:selected]
    
    if value
      "<input name=\"#{@object_name}[#{attribute_name}]\" value=\"#{value}\" />"
    else
      "<input name=\"#{@object_name}[#{attribute_name}]\" />"
    end
  end
  
  # Now include the extension which will alias the input method
  include AutoFormFaker::SimpleFormExtension
end

RSpec.describe AutoFormFaker::SimpleFormExtension do
    let(:form_builder) { MockSimpleFormBuilder.new }

    before do
      stub_const('Rails', MockRails)
      Rails.env = 'development'
      allow(AutoFormFaker).to receive(:enabled?).and_return(true)
    end

    describe '#input with auto_faker options' do
      it 'applies fake data when auto_faker is true in input_html' do
        allow(Faker::Name).to receive(:name).and_return('John Doe')
        
        result = form_builder.input(:name, input_html: { auto_faker: true })
        
        expect(result).to include('value="John Doe"')
      end

      it 'uses custom faker class when specified' do
        result = form_builder.input(:planet, input_html: { 
          auto_faker: true, 
          auto_faker_class: 'Faker::Space.galaxy' 
        })
        
        expect(result).to include('value=')
        expect(result).not_to include('auto_faker')
      end

      it 'uses specific ID for association fields' do
        result = form_builder.input(:user_id, input_html: { auto_faker: 123 })
        
        expect(result).to include('value="123"')
      end

      it 'does not apply fake data when auto_faker is false' do
        result = form_builder.input(:name, input_html: { auto_faker: false })
        
        expect(result).not_to include('value=')
      end

      it 'removes auto_faker options from final input_html' do
        result = form_builder.input(:name, input_html: { 
          auto_faker: true, 
          auto_faker_class: 'Faker::Name.name',
          class: 'form-control'
        })
        
        expect(result).not_to include('auto_faker')
        expect(result).not_to include('auto_faker_class')
      end
    end

    describe 'context-aware field detection for SimpleForm' do
      it 'detects email fields' do
        allow(Faker::Internet).to receive(:email).and_return('test@example.com')
        
        result = form_builder.input(:email, input_html: { auto_faker: true })
        
        expect(result).to include('value="test@example.com"')
      end

      it 'detects movie names using pattern matching' do
        allow(Faker::Movie).to receive(:title).and_return('The Matrix')
        
        result = form_builder.input(:movie_name, input_html: { auto_faker: true })
        
        expect(result).to include('value="The Matrix"')
      end
    end

    describe 'collection inputs' do
      it 'handles select inputs with collections' do
        result = form_builder.input(:category_id, 
          collection: [['Active', 1], ['Inactive', 2]], 
          input_html: { auto_faker: 1 }
        )
        
        expect(result).to include('value="1"')
      end

      it 'handles explicit select type' do
        result = form_builder.input(:status, 
          as: :select,
          input_html: { auto_faker: 'active' }
        )
        
        expect(result).to include('value="active"')
      end
    end

    describe 'custom field mappings' do
      before do
        AutoFormFaker.configure do |config|
          config.field_mappings = {
            'superhero_name' => -> { 'Batman' }
          }
        end
      end

      it 'uses custom mappings for SimpleForm inputs' do
        result = form_builder.input(:superhero_name, input_html: { auto_faker: true })
        
        expect(result).to include('value="Batman"')
      end
    end

    describe 'environment detection' do
      it 'does not apply fake data when disabled' do
        allow(AutoFormFaker).to receive(:enabled?).and_return(false)
        
        result = form_builder.input(:name, input_html: { auto_faker: true })
        
        expect(result).not_to include('value=')
      end
    end
  end

