module AutoFormFaker
  module SimpleFormExtension
    def self.included(base)
      base.class_eval do
        alias_method :original_input, :input

        def input(attribute_name, options = {}, &block)
          options = apply_auto_faker_to_simple_form(attribute_name, options)
          original_input(attribute_name, options, &block)
        end

        private

        def apply_auto_faker_to_simple_form(attribute_name, options)
          return options unless AutoFormFaker.enabled?
          
          # Check for auto_faker in input_html options
          input_html = options[:input_html] || {}
          auto_faker = input_html.delete(:auto_faker)
          auto_faker_class = input_html.delete(:auto_faker_class)
          
          return options unless auto_faker

          # Generate fake value
          faker_value = generate_simple_form_faker_value(attribute_name, auto_faker, auto_faker_class, options)
          
          if faker_value
            # For collection inputs, set the selected value
            if options[:collection] || detect_collection_input(options)
              options[:selected] = faker_value
            else
              # For regular inputs, add value to input_html
              input_html[:value] = faker_value
            end
          end

          # Clean up and return options
          options[:input_html] = input_html
          options
        end

        def generate_simple_form_faker_value(attribute_name, auto_faker, auto_faker_class, options)
          # Priority 1: auto_faker_class (explicit override)
          if auto_faker_class
            return execute_faker_class(auto_faker_class)
          end

          # Priority 2: Handle explicit values and lambdas
          case auto_faker
          when Integer, String
            return auto_faker
          when Proc
            return auto_faker.call
          when true
            # Continue to pattern matching
          else
            return nil
          end

          # Priority 3: Pattern-based mapping
          pattern_faker = AutoFormFaker::FieldMappings.find_mapping(attribute_name)
          return pattern_faker.call if pattern_faker

          # Priority 4: SimpleForm type detection
          input_type = detect_simple_form_input_type(attribute_name, options)
          default_faker = get_default_faker_for_type(input_type)
          return default_faker.call if default_faker

          # Priority 5: Association ID detection
          if attribute_name.to_s.end_with?('_id')
            association_id = generate_random_association_id(attribute_name)
            return association_id if association_id
          end

          # Fallback
          Faker::Lorem.word
        end

        def detect_simple_form_input_type(attribute_name, options)
          # Check explicit :as option first
          return options[:as] if options[:as]

          # Try to infer from attribute name or other clues
          case attribute_name.to_s
          when /email/i
            :email
          when /phone/i
            :phone
          when /password/i
            :password
          when /url|website/i
            :url
          when /text|description|bio|comment/i
            :text
          when /_id$/
            :select
          else
            :string
          end
        end

        def get_default_faker_for_type(input_type)
          case input_type
          when :email
            -> { Faker::Internet.email }
          when :phone
            -> { Faker::PhoneNumber.phone_number }
          when :password
            -> { Faker::Internet.password }
          when :url
            -> { Faker::Internet.url }
          when :text
            -> { Faker::Lorem.paragraph }
          when :integer, :number
            -> { Faker::Number.number(digits: 5) }
          else
            -> { Faker::Lorem.word }
          end
        end

        def detect_collection_input(options)
          # Only treat as collection input if there's actually a collection
          # or if it's radio_buttons/check_boxes which always need collections
          options.key?(:collection) || 
          options[:as] == :radio_buttons || 
          options[:as] == :check_boxes
        end

        def execute_faker_class(faker_class_string)
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
          nil
        rescue => e
          Rails.logger.warn "AutoFormFaker: Error generating association ID for #{field_name}: #{e.message}" if defined?(Rails)
          nil
        end
      end
    end
  end
end