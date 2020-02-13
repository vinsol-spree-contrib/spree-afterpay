module Spree::AfterpayApi
  class Payment

    attr_reader :order, :payment, :afterpay_source, :options, :afterpay_payment, :transaction_id

    def initialize(order, payment, afterpay_source, options = {})
      @order = order
      @payment = payment
      @afterpay_source = afterpay_source
      @options = options
      @transaction_id = nil
    end

    def capture
      @afterpay_payment = Afterpay::Payment.execute(
        token: afterpay_source.token,
        reference: order.number
      )
      if @afterpay_payment.success?
        @transaction_id = @afterpay_payment.id
      end
    end

    def success?
      @afterpay_payment.success?
    end

  end
end
