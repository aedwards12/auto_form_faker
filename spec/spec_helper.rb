require 'bundler/setup'
require 'auto_form_faker'
require 'rails'
require 'action_view'
require 'faker'

# Try to load SimpleForm
begin
  require 'simple_form'
rescue LoadError
  # SimpleForm not available
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    AutoFormFaker.reset_configuration!
  end
end

# Mock Rails environment
class MockRails
  def self.env
    @env ||= ActiveSupport::StringInquirer.new('development')
  end

  def self.env=(environment)
    @env = ActiveSupport::StringInquirer.new(environment.to_s)
  end
end

# Mock ActionView context for testing
class MockActionView
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include AutoFormFaker::FormHelperExtension

  def initialize
    @output_buffer = ""
  end
end