require 'minitest/autorun'
require 'rails_event_store'

require_relative './test_helper'
require_relative '../payment'

module Payment
  class TestPayment < Minitest::Test
    include Import['event_store', 'command_bus', 'repository']

    def test_that_it_responds_to_capture_events
      # Given
      order = Order.new
      order.place('my-product-id')
      refute(order.can_be_delivered?)
      repository.store(order, 'Order:my-order-id')

      # When
      captured_event = Payment::Captured.new(data: { amount: 5000, order_id: 'my-order-id' })
      event_store.publish(captured_event)

      # Then
      repository.with_aggregate(Order.new, 'Order:my-order-id') do |o|
        assert(o.can_be_delivered?)
      end
    end
  end
end
