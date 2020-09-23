require 'test_helper'

class PaymentProcessTest < ActiveSupport::TestCase
  test 'it_responds_to_capture_events' do
    # Given
    order = Fulfillment::Order.new('my-order-id')
    order.place(5000, 'my-product-id')
    refute(order.can_be_delivered?)
    repository.store(order, order.stream_name)

    # When
    payment = Payment::Payment.new('my-payment-id', :paypay)
    payment.authorize(5000, 'my-order-id')
    payment.capture
    repository.store(payment, payment.stream_name)

    # Then
    order = Fulfillment::Order.new('my-order-id')
    repository.with_aggregate(order, order.stream_name) do |o|
      assert(o.can_be_delivered?)
    end
  end
end
