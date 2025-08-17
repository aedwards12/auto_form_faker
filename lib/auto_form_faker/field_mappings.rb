module AutoFormFaker
  module FieldMappings
    DEFAULT_MAPPINGS = {
      # Entertainment (must come before general names)
      /movie.*name|film.*name|movie.*title|film.*title/i => -> { Faker::Movie.title },
      /book.*name|book.*title/i => -> { Faker::Book.title },
      /song.*name|song.*title/i => -> { Faker::Music.song },
      /band.*name|artist.*name/i => -> { Faker::Music.band },
      
      # Business (must come before general names)
      /company.*name|business.*name/i => -> { Faker::Company.name },
      /job.*title|position/i => -> { Faker::Job.title },
      /department/i => -> { Faker::Commerce.department },
      /product.*name/i => -> { Faker::Commerce.product_name },
      
      # Names (more general, should come after specific patterns)
      /first_name|fname/i => -> { Faker::Name.first_name },
      /last_name|lname|surname/i => -> { Faker::Name.last_name },
      /full_name|(?<!movie_|film_|company_|product_|book_|song_|band_)name$/i => -> { Faker::Name.name },
      
      # Location
      /city/i => -> { Faker::Address.city },
      /state|province/i => -> { Faker::Address.state },
      /country/i => -> { Faker::Address.country },
      /address/i => -> { Faker::Address.full_address },
      /street/i => -> { Faker::Address.street_address },
      /zip.*code|postal.*code/i => -> { Faker::Address.zip_code },
      
      # Contact
      /email/i => -> { Faker::Internet.email },
      /phone.*number|phone/i => -> { Faker::PhoneNumber.phone_number },
      /website|url/i => -> { Faker::Internet.url },
      
      # Tech
      /username/i => -> { Faker::Internet.username },
      /password/i => -> { Faker::Internet.password },
      /ip.*address/i => -> { Faker::Internet.ip_v4_address },
      
      # General
      /description|bio/i => -> { Faker::Lorem.paragraph },
      /comment/i => -> { Faker::Lorem.sentence },
      /title$/i => -> { Faker::Lorem.sentence(word_count: 3) },
      /age/i => -> { Faker::Number.between(from: 18, to: 99) },
      /price|amount|cost/i => -> { Faker::Commerce.price },
      /color/i => -> { Faker::Color.color_name }
    }.freeze

    def self.find_mapping(field_name)
      # Check custom mappings first (exact matches have priority)
      AutoFormFaker.configuration.field_mappings.each do |pattern, faker_proc|
        if pattern.is_a?(String) || pattern.is_a?(Symbol)
          return faker_proc if field_name.to_s == pattern.to_s
        end
      end
      
      # Then check custom regex patterns
      AutoFormFaker.configuration.field_mappings.each do |pattern, faker_proc|
        if pattern.is_a?(Regexp)
          return faker_proc if field_name.to_s.match?(pattern)
        end
      end
      
      # Finally check default patterns (unless overridden)
      unless AutoFormFaker.configuration.override_defaults
        DEFAULT_MAPPINGS.each do |pattern, faker_proc|
          if pattern.is_a?(Regexp)
            return faker_proc if field_name.to_s.match?(pattern)
          elsif pattern.is_a?(String) || pattern.is_a?(Symbol)
            return faker_proc if field_name.to_s == pattern.to_s
          end
        end
      end
      
      nil
    end
  end
end