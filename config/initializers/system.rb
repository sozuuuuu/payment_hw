require 'arkency/command_bus'
require 'aggregate_root'

Dry::Rails.container do
  event_store = RailsEventStore::Client.new
  register(:event_store, event_store)

  command_bus = Arkency::CommandBus.new
  register(:command_bus, command_bus)

  AggregateRoot.configure do |config|
    config.default_event_store = event_store
  end

  repository = AggregateRoot::Repository.new
  register(:repository, repository)
end
