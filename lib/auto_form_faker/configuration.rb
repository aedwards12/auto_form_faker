module AutoFormFaker
  class Configuration
    attr_accessor :enabled_environments, :field_mappings, :override_defaults

    def initialize
      @enabled_environments = [:development, :staging]
      @field_mappings = {}
      @override_defaults = false
    end

    def all_field_mappings
      if override_defaults
        field_mappings
      else
        FieldMappings::DEFAULT_MAPPINGS.merge(field_mappings)
      end
    end
  end
end