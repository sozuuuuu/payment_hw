# MerchantBC
OrderAggregate
#place
  payment_gateway#authorize(5000, token)
#ship

when authorized -> ship
when fulfilled -> capture

# PaymentBC
PaymentAggregate
#charge # OOS
#authorize
#capture
#release
#refund

Charged
Authorized
Captured
Released
Refunded?

# FulfillmentBC
Process Manager : FulfillmentProcess
takes PaymentEvents
#can_be_delivered?
#deliver_order -> DeliverOrderCommand