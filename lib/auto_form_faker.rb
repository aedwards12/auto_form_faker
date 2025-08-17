require_relative "auto_form_faker/version"
require_relative "auto_form_faker/configuration"
require_relative "auto_form_faker/field_mappings"
require_relative "auto_form_faker/form_helper_extension"
require_relative "auto_form_faker/simple_form_extension"
require_relative "auto_form_faker/railtie" if defined?(Rails)

module AutoFormFaker
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end

    def enabled?
      return false unless defined?(Rails)
      configuration.enabled_environments.include?(Rails.env.to_sym)
    end
  end
end