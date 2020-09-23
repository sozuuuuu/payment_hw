require 'aggregate_root'

module Payment
  Authorized = Class.new(RailsEventStore::Event)
  Captured = Class.new(RailsEventStore::Event)

  class Payment
    include AggregateRoot

    def initialize(payment_id, gateway)
      @payment_id = payment_id
      @gateway = gateway
    end

    def authorize(amount, order_id)
      apply Authorized.new(data: { amount: amount, order_id: order_id, payment_id: @payment_id, gateway: @gateway })
    end

    def capture(amount = :all)
      apply Captured.new(data: { amount: amount, order_id: @order_id, payment_id: @payment_id, gateway: @gateway})
    end

    def stream_name
      "Payment$#{@payment_id}"
    end

    private

    def apply_authorized(event)
      @state = :authorized
      @amount = event.data.fetch(:amount)
      @order_id = event.data.fetch(:order_id)
    end

    def apply_captured(event)
      @state = :captured

      unless (amount = event.data.fetch(:amount)) == :all
        @remaining = amount
      end
    end
  end
end
