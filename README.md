# AutoFormFaker

A Rails gem that automatically fills form fields with realistic fake data using the Faker gem. Perfect for development and staging environments where you want to quickly test forms without manually entering data.

## Features

- 🎯 **Explicit Control**: Only fields with `auto_faker: true` get fake data
- 🧠 **Context-Aware**: Intelligently detects field types (movie_name → movie titles, company_name → company names)
- 🎭 **Custom Faker Classes**: Override with specific `auto_faker_class: "Faker::Space.galaxy"`
- 🔗 **Association Support**: Handle association IDs with `auto_faker: 123` or random IDs
- 🛡️ **Environment Safe**: Only works in development/staging by default
- ⚙️ **Configurable**: Custom field mappings and environment settings

## Installation

Add to your Gemfile:

```ruby
gem 'auto_form_faker'
```

Then run:
```bash
bundle install
```

## Usage

### Basic Usage

```ruby
<%= form_with model: @user do |f| %>
  <%= f.text_field :name, auto_faker: true %>           # Gets fake name
  <%= f.email_field :email, auto_faker: true %>         # Gets fake email
  <%= f.text_field :company %>                          # No fake data
<% end %>
```

### Context-Aware Field Detection

The gem intelligently detects field context:

```ruby
<%= f.text_field :movie_name, auto_faker: true %>      # → "The Dark Knight"
<%= f.text_field :company_name, auto_faker: true %>    # → "Acme Corp"
<%= f.text_field :city, auto_faker: true %>            # → "New York"
<%= f.text_field :first_name, auto_faker: true %>      # → "John"
```

### Custom Faker Classes

Override the default faker with specific methods:

```ruby
<%= f.text_field :planet, auto_faker: true, auto_faker_class: "Faker::Space.galaxy" %>
<%= f.text_field :hero, auto_faker: true, auto_faker_class: "Faker::Superhero.name" %>
<%= f.password_field :pwd, auto_faker: true, auto_faker_class: "Faker::Internet.password(min_length: 8)" %>
```

### Association Fields

Handle association IDs:

```ruby
# Specific association ID
<%= f.number_field :user_id, auto_faker: 123 %>

# Random existing record ID
<%= f.number_field :user_id, auto_faker: true %>  # Finds random User.pluck(:id).sample

# Custom logic
<%= f.number_field :user_id, auto_faker: -> { User.active.pluck(:id).sample } %>
```

### Select Fields

Works with select fields too:

```ruby
<%= f.select :category_id, options_from_collection_for_select(Category.all, :id, :name), 
    {}, { auto_faker: true } %>  # Randomly selects a category

<%= f.select :status, [['Active', 1], ['Inactive', 0]], 
    {}, { auto_faker: 1 } %>     # Selects 'Active'
```

## Configuration

Create an initializer `config/initializers/auto_form_faker.rb`:

```ruby
AutoFormFaker.configure do |config|
  # Which environments to enable (default: [:development, :staging])
  config.enabled_environments = [:development, :staging, :test]
  
  # Custom field mappings
  config.field_mappings = {
    # Regex patterns
    /product.*name/i => -> { Faker::Commerce.product_name },
    /pet.*name/i => -> { Faker::Creature::Dog.name },
    
    # Exact field names
    'superhero_name' => -> { Faker::Superhero.name },
    'spaceship_model' => -> { Faker::Space.galaxy },
    
    # Custom business logic
    /project_code/i => -> { "PROJ-#{Faker::Alphanumeric.alpha(number: 3).upcase}-#{rand(1000..9999)}" }
  }
  
  # Override built-in mappings (default: false, which merges with defaults)
  config.override_defaults = false
end
```

## Built-in Field Mappings

The gem includes intelligent defaults for common field patterns:

| Pattern | Faker Method | Example Output |
|---------|-------------|----------------|
| `movie_name`, `film_title` | `Faker::Movie.title` | "Inception" |
| `company_name` | `Faker::Company.name` | "Acme Corp" |
| `first_name` | `Faker::Name.first_name` | "John" |
| `email` | `Faker::Internet.email` | "john@example.com" |
| `phone` | `Faker::PhoneNumber.phone_number` | "555-1234" |
| `city` | `Faker::Address.city` | "New York" |
| `description`, `bio` | `Faker::Lorem.paragraph` | "Lorem ipsum..." |

## Field Types Supported

- `text_field`
- `email_field` 
- `phone_field`
- `number_field`
- `password_field`
- `text_area`
- `select`
- `collection_select`

## Priority Order

The gem determines what fake data to use in this order:

1. **`auto_faker_class`** (highest priority)
2. **Exact field name matches** in config
3. **Custom regex patterns** in config  
4. **Built-in regex patterns**
5. **Field type defaults** (lowest priority)

## Environment Safety

By default, AutoFormFaker only works in `:development` and `:staging` environments. In production, all `auto_faker` options are ignored for safety.

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the [MIT License](https://opensource.org/licenses/MIT).