require 'aggregate_root'

module Fulfillment
  MarkAsPaid = Struct.new(:order_id, :gateway)

  class CommandHandler
  end

  class OnMarkAsPaid < CommandHandler
    def call(command)
      order = Order.new(command.order_id)
      loaded = repository.load(order, order.stream_name)
      loaded.mark_as_paid(command.gateway)
      repository.store(loaded, order.stream_name)
    end
  end

  class OrderPlaced < RailsEventStore::Event; end
  class OrderShipped < RailsEventStore::Event; end
  class MarkedAsPaid < RailsEventStore::Event; end

  class Order
    include AggregateRoot

    def initialize(order_id)
      @order_id = order_id
    end

    def place(amount, product_id)
      apply OrderPlaced.new(data: { amount: amount, order_id: @order_id, product_id: product_id })
    end

    def can_be_delivered?
      @has_paid && @state == :placed
    end

    def mark_as_paid(gateway)
      apply MarkedAsPaid.new(data: { gateway: gateway })
    end

    def stream_name
      "Order$#{@order_id}"
    end

    private

    def apply_order_placed(_event)
      @state = :placed
      @has_paid = false
    end

    def apply_marked_as_paid(_event)
      @has_paid = true
    end
  end
end
