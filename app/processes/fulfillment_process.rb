# This process simply subscribe events from Payments bounded context
# and mutate aggregate state in Fulfillment bounded context.
class FulfillmentProcess
  include PaymentHw::Deps[:event_store, :command_bus]

  def call(event)
    case event
    when Payment::Captured
      command = Fulfillment::MarkAsPaid.new(event.data.fetch(:order_id), event.data.fetch(:gateway))
      command_bus.(command)
    end
  end
end
