require 'faker'

module AutoFormFaker
  module FormHelperExtension
    def self.included(base)
      base.class_eval do
        alias_method :original_text_field, :text_field
        alias_method :original_email_field, :email_field
        alias_method :original_phone_field, :phone_field
        alias_method :original_number_field, :number_field
        alias_method :original_password_field, :password_field
        alias_method :original_text_area, :text_area
        
        if method_defined?(:select)
          alias_method :original_select, :select
        end
        
        if method_defined?(:collection_select)
          alias_method :original_collection_select, :collection_select
        end

        def text_field(object_name, method, options = {})
          options = apply_auto_faker(object_name, method, options)
          original_text_field(object_name, method, options)
        end

        def email_field(object_name, method, options = {})
          options = apply_auto_faker(object_name, method, options, default_faker: -> { Faker::Internet.email })
          original_email_field(object_name, method, options)
        end

        def phone_field(object_name, method, options = {})
          options = apply_auto_faker(object_name, method, options, default_faker: -> { Faker::PhoneNumber.phone_number })
          original_phone_field(object_name, method, options)
        end

        def number_field(object_name, method, options = {})
          options = apply_auto_faker(object_name, method, options, default_faker: -> { Faker::Number.number(digits: 5) })
          original_number_field(object_name, method, options)
        end

        def password_field(object_name, method, options = {})
          options = apply_auto_faker(object_name, method, options, default_faker: -> { Faker::Internet.password })
          original_password_field(object_name, method, options)
        end

        def text_area(object_name, method, options = {})
          options = apply_auto_faker(object_name, method, options, default_faker: -> { Faker::Lorem.paragraph })
          original_text_area(object_name, method, options)
        end

        if method_defined?(:select)
          def select(object_name, method, choices = nil, options = {}, html_options = {}, &block)
            html_options = apply_auto_faker_to_select(object_name, method, html_options, choices)
            original_select(object_name, method, choices, options, html_options, &block)
          end
        end

        if method_defined?(:collection_select)
          def collection_select(object_name, method, collection, value_method, text_method, options = {}, html_options = {})
            html_options = apply_auto_faker_to_collection_select(object_name, method, html_options, collection, value_method)
            original_collection_select(object_name, method, collection, value_method, text_method, options, html_options)
          end
        end

        private

        def apply_auto_faker(object_name, method, options, default_faker: nil)
          return options unless AutoFormFaker.enabled?
          return options unless options[:auto_faker]

          faker_value = generate_faker_value(method, options[:auto_faker], options[:auto_faker_class], default_faker)
          
          if faker_value && !options.key?(:value)
            options = options.merge(value: faker_value)
          end

          options.except(:auto_faker, :auto_faker_class)
        end

        def apply_auto_faker_to_select(object_name, method, html_options, choices)
          return html_options unless AutoFormFaker.enabled?
          return html_options unless html_options[:auto_faker]

          faker_value = generate_faker_value(method, html_options[:auto_faker], html_options[:auto_faker_class])
          
          if faker_value
            if choices.is_a?(Array) && faker_value.is_a?(Integer)
              # For select with array of arrays [[text, value], ...]
              valid_values = choices.map { |choice| choice.is_a?(Array) ? choice.last : choice }
              html_options[:selected] = valid_values.include?(faker_value) ? faker_value : valid_values.sample
            else
              html_options[:selected] = faker_value
            end
          end

          html_options.except(:auto_faker, :auto_faker_class)
        end

        def apply_auto_faker_to_collection_select(object_name, method, html_options, collection, value_method)
          return html_options unless AutoFormFaker.enabled?
          return html_options unless html_options[:auto_faker]

          faker_value = generate_faker_value(method, html_options[:auto_faker], html_options[:auto_faker_class])
          
          if faker_value
            if faker_value.is_a?(Integer) && collection.respond_to?(:map)
              # Get valid IDs from collection
              valid_ids = collection.map { |item| item.send(value_method) }
              html_options[:selected] = valid_ids.include?(faker_value) ? faker_value : valid_ids.sample
            else
              html_options[:selected] = faker_value
            end
          end

          html_options.except(:auto_faker, :auto_faker_class)
        end

        def generate_faker_value(field_name, auto_faker_option, auto_faker_class = nil, default_faker = nil)
          # Priority 1: auto_faker_class (explicit override)
          if auto_faker_class
            return execute_faker_class(auto_faker_class)
          end

          # Priority 2: Handle association IDs and lambdas
          case auto_faker_option
          when Integer
            return auto_faker_option
          when Proc
            return auto_faker_option.call
          when true
            # Continue to pattern matching
          else
            return nil
          end

          # Priority 3: Pattern-based mapping
          pattern_faker = AutoFormFaker::FieldMappings.find_mapping(field_name)
          return pattern_faker.call if pattern_faker

          # Priority 4: Association ID detection
          if field_name.to_s.end_with?('_id')
            association_id = generate_random_association_id(field_name)
            return association_id if association_id
          end

          # Priority 5: Default faker for field type
          return default_faker.call if default_faker

          # Fallback
          Faker::Lorem.word
        end

        def execute_faker_class(faker_class_string)
          # Handle method calls with arguments like "Faker::Internet.password(min_length: 8)"
          eval(faker_class_string)
        rescue => e
          Rails.logger.warn "AutoFormFaker: Invalid faker class '#{faker_class_string}': #{e.message}" if defined?(Rails)
          Faker::Lorem.word
        end

        def generate_random_association_id(field_name)
          model_name = field_name.to_s.chomp('_id').classify
          model_class = model_name.constantize
          ids = model_class.pluck(:id)
          ids.sample if ids.any?
        rescue NameError
          # Model doesn't exist, return nil
          nil
        rescue => e
          Rails.logger.warn "AutoFormFaker: Error generating association ID for #{field_name}: #{e.message}" if defined?(Rails)
          nil
        end
      end
    end
  end
end