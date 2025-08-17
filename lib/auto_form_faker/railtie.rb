module AutoFormFaker
  class Railtie < Rails::Railtie
    initializer "auto_form_faker.initialize" do
      ActiveSupport.on_load(:action_view) do
        include AutoFormFaker::FormHelperExtension
      end
    end
  end
end