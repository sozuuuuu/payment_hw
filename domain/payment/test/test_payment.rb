require 'minitest/autorun'
require 'rails_event_store'

require_relative './test_helper'
require_relative '../payment'

module Payment
  class TestPayment < Minitest::Test
    include Import['event_store', 'command_bus', 'repository']

    def test_that_it_responds_to_authorize
      payment = Payment.new('my-payment-id')
      stream = 'Payment:Payment$my-payment-id'
      before = event_store.read.stream(stream).each.to_a
      payment.authorize(5000)
      after = event_store.read.stream(stream).each.to_a
      published_events = after.reject { |a| before.any? { |b| a.event_id == b.event_id } }
      pp published_events
      pp event_store.read.limit(100).to_a
    end
  end
end
