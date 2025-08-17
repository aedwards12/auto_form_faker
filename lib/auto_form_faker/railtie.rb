module AutoFormFaker
  class Railtie < Rails::Railtie
    initializer "auto_form_faker.initialize" do
      ActiveSupport.on_load(:action_view) do
        include AutoFormFaker::FormHelperExtension
      end
      
      # Include SimpleForm extension if SimpleForm is available
      config.after_initialize do
        if defined?(SimpleForm)
          SimpleForm::FormBuilder.include(AutoFormFaker::SimpleFormExtension)
        end
      end
    end
  end
end