require 'dry-container'
require 'aggregate_root'
require 'arkency/command_bus'
require 'dry-auto_inject'

class Container
  extend Dry::Container::Mixin
end

event_store = RailsEventStore::Client.new(
  mapper: RubyEventStore::Mappers::Default.new(serializer: JSON),
  repository: RubyEventStore::InMemoryRepository.new
)
Container.register(:event_store, event_store)
command_bus = Arkency::CommandBus.new
Container.register(:command_bus, command_bus)
AggregateRoot.configure do |config|
  config.default_event_store = event_store
end
repository = AggregateRoot::Repository.new
Container.register(:repository, repository)

Import = Dry::AutoInject(Container)
