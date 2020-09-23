require 'test_helper'

module Queries
  class PaymentProcessTest < ActiveSupport::TestCase
    test 'it_responds_to_capture_events' do
      # Given
      order = ::Fulfillment::Order.new('my-order-id')
      order.place(5000, 'my-product-id')
      refute(order.can_be_delivered?)
      repository.store(order, order.stream_name)

      # When
      payment = ::Payment::Payment.new('my-payment-id', :paypay)
      payment.authorize(5000, 'my-order-id')
      payment.capture
      repository.store(payment, payment.stream_name)

      # Then
      fulfillment = Queries::Fulfillment.find_by(order_id: 'my-order-id')
      assert_equal('paypay', fulfillment.payment_gateway)
      assert_equal('my-product-id', fulfillment.product_id)
      assert_equal('my-payment-id', fulfillment.payment_id)
    end
  end
end
