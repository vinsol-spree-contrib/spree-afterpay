module Spree
  class AfterpayRequestService
    attr_reader :order, :payment, :afterpay_source, :options, :payment_request

    def initialize(afterpay_source, options = {})
      @afterpay_source = afterpay_source
      @payment = afterpay_source.payment
      @order = @payment.order
      @options = options
    end

    def checkout
      @checkout_request = Spree::AfterpayApi::Checkout.new(order, payment, afterpay_source, options)
      @checkout_request.perform
      @checkout_request.success?
    end

    def capture
      @payment_request = Spree::AfterpayApi::Payment.new(order, payment, afterpay_source, options)
      @payment_request.capture
      @payment_request
    end

    def refund
      @refund_request = Spree::AfterpayApi::Refund.new(order, payment, afterpay_source, options[:amount], options)
      @refund_request.refund
      @refund_request
    end

  end
end
