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
        # total: Money.new(payment.amount * 100, 'AUD'),
        total: Money.new(payment.amount * 100, options[:currency] || Spree::Config.currency),
        consumer: customer,
        items: items,
        success_url: Spree.railtie_routes_url_helpers.success_afterpay_url(order, host: host_url),
        cancel_url: Spree.railtie_routes_url_helpers.cancel_afterpay_url(order, host: host_url),
        reference: order.number,
        billing_address: billing_address,
        shipping_address: shipping_address,
        # shipping: Money.new(order.shipment_total * 100, 'AUD')
        shipping: Money.new(order.shipment_total * 100, options[:currency] || Spree::Config.currency)
      )
    end

    def send_create_order_request
      @response = @afterpay_order.create
      if @response.success?
        afterpay_source.update_columns(token: @response.token, expire_at: @response.expiry)
      end
    end

    def build_customer_params
      @customer = Afterpay::Consumer.new(
                    email: order&.email || order.user&.email,
                    phone: order.billing_address&.phone || order.user&.billing_address&.phone,
                    first_name: order.billing_address&.firstname,
                    last_name: order.billing_address&.lastname
                  )
    end

    def build_address_params(address_type)
      address = order.public_send(address_type)
      instance_variable_set("@#{address_type.to_s}", Afterpay::Address.new(
                            name: address&.firstname,
                            line_1: address&.address1,
                            line_2: address&.address2,
                            suburb: address&.city,
                            state: address&.state&.name,
                            postcode: address&.zipcode,
                            country: address&.country&.iso,
                            phone: address&.phone
                          ))
    end

    def build_line_item_params
      order.line_items.each do |line_item|
        items << Afterpay::Item.new(
          name: line_item.name,
          # price: Money.new(line_item.price * 100, 'AUD'),
          price: Money.new(line_item.price * 100, options[:currency] || Spree::Config.currency),
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
