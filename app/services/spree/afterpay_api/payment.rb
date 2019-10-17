module Spree::AfterpayApi
  class Payment

    attr_reader :order, :payment, :afterpay_source, :options, :afterpay_payment

    def initialize(order, payment, afterpay_source, options = {})
      @order = order
      @payment = payment
      @afterpay_source = afterpay_source
      @options = options
    end

    def capture
      @afterpay_payment = Afterpay::Payment.execute(
        token: afterpay_source.transaction_id,
        reference: order.number
      )
    end

    def success?
      @afterpay_payment.success?
    end

  end
end
