user = Gemgento::User.find(5)
cart = Gemgento::Order.get_cart(user)
product = Gemgento::Product.find(10)
cart.add_item(product)

cart.push_cart

cart.shipping_address = user.addresses.first
cart.billing_address = user.addresses.first

order_payment = Gemgento::OrderPayment.new
order_payment.method = 'checkmo'
order_payment.order = cart
order_payment.save

cart.shipping_method = cart.get_shipping_methods[0]

cart.process