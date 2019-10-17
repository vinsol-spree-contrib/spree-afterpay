module Spree::AfterpayApi
  class Checkout
    attr_reader :order, :payment, :afterpay_source, :options,
                :customer, :items, :shipping_address, :billing_address, :discount, :afterpay_order

    def initialize(order, payment, afterpay_source, options = {})
      @order = order
      @payment = payment
      @afterpay_source = afterpay_source
      @options = options
      @items = Array.new
    end

    def perform
      build_order_params
      build_afterpay_order
      send_create_order_request
    end

    def success?
      @response && @response.success?
    end

    private

    def build_order_params
      build_customer_params
      build_address_params(:shipping_address)
      build_address_params(:billing_address)
      build_line_item_params
    end

    def build_afterpay_order
      @afterpay_order = Afterpay::Order.new(
        total: Money.new(payment.amount * 100, 'AUD'),
        consumer: customer,
        items: items,
        success_url: Spree.railtie_routes_url_helpers.success_afterpay_url(order, host: host_url),
        cancel_url: Spree.railtie_routes_url_helpers.cancel_afterpay_url(order, host: host_url),
        reference: order.number,
        billing_address: billing_address,
        shipping_address: shipping_address,
        shipping: Money.new(order.shipment_total * 100, 'AUD')
      )
    end

    def send_create_order_request
      @response = @afterpay_order.create
      if @response.success?
        afterpay_source.update_columns(transaction_id: @response.token, expire_at: @response.expiry)
      end
    end

    def build_customer_params
      @customer = Afterpay::Consumer.new(
                    email: order.user&.email || order&.email,
                    phone: order.user&.ship_address&.phone || order.ship_address&.phone,
                    first_name: order.ship_address&.firstname,
                    last_name: order.ship_address&.lastname
                  )
    end

    def build_address_params(address_type)
      instance_variable_set("@#{address_type.to_s}", Afterpay::Address.new(
                            name: order.send(address_type)&.firstname,
                            line_1: order.send(address_type)&.address1,
                            line_2: order.send(address_type)&.address2,
                            suburb: order.send(address_type)&.city,
                            state: order.send(address_type)&.state&.name,
                            postcode: order.send(address_type)&.zipcode,
                            country: order.send(address_type)&.country&.iso,
                            phone: order.send(address_type)&.phone
                          ))
    end

    def build_line_item_params
      order.line_items.each do |line_item|
        items << Afterpay::Item.new(
          name: line_item.name,
          price: Money.new(line_item.price * 100, 'AUD'),
          sku: line_item.sku,
          quantity: line_item.quantity,
        )
      end
    end

    def host_url
      Spree::Store.current.url
    end

  end
end
