require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PaymentHw
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.after_initialize do
      Fulfillment::CommandHandler.include(PaymentHw::Deps[:repository])

      event_store = PaymentHw::Container.resolve(:event_store)
      event_store.subscribe(FulfillmentProcess, to: [Payment::Captured])
      event_store.subscribe(Queries::Fulfillment.on_order_placed, to: [Fulfillment::OrderPlaced])
      event_store.subscribe(Queries::Fulfillment.on_payment_authorized, to: [Payment::Authorized])
      event_store.subscribe(Queries::Fulfillment.on_payment_captured, to: [Payment::Captured])

      command_bus = PaymentHw::Container.resolve(:command_bus)
      command_bus.register(Fulfillment::MarkAsPaid, Fulfillment::OnMarkAsPaid.new)
    end
  end
end
