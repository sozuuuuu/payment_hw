class CreateFulfillments < ActiveRecord::Migration[6.0]
  def change
    create_table :fulfillments do |t|
      t.string :order_id
      t.string :payment_gateway
      t.string :product_id
      t.string :payment_id
      t.boolean :paid
    end
  end
end
