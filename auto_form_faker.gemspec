require_relative "lib/auto_form_faker/version"

Gem::Specification.new do |spec|
  spec.name        = "auto_form_faker"
  spec.version     = AutoFormFaker::VERSION
  spec.authors     = ["Anthony Edwards Jr"]
  spec.email       = ["anthony@eatokra.com"]
  spec.homepage    = "https://github.com/anthonyedwardsjr/auto_form_faker"
  spec.summary     = "Auto-fill Rails forms with fake data in development"
  spec.description = "A Rails gem that automatically fills form fields with realistic fake data using the Faker gem when auto_faker option is enabled"
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.7.0"
  
  spec.add_dependency "rails", ">= 6.0"
  spec.add_dependency "faker", "~> 3.0"
  
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "simple_form", ">= 5.0"
end