module Queries
  class Fulfillment < ApplicationRecord
    def self.on_order_placed
      ->(event) { create!(order_id: event.data.fetch(:order_id), product_id: event.data.fetch(:product_id)) }
    end

    def self.on_payment_authorized
      ->(event) { find_by(order_id: event.data.fetch(:order_id)).update!(payment_gateway: event.data.fetch(:gateway), payment_id: event.data.fetch(:payment_id)) }
    end

    def self.on_payment_captured
      ->(event) { find_by(order_id: event.data.fetch(:order_id)).update!(paid: true) }
    end
  end
end
