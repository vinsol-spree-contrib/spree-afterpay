module Spree::AfterpayApi
  class Refund

    attr_reader :order, :payment, :afterpay_source, :options, :afterpay_refund, :refund_id, :amount

    def initialize(order, payment, afterpay_source, amount, options = {})
      @order = order
      @payment = payment
      @afterpay_source = afterpay_source
      @options = options
      @transaction_id = nil
      @amount = amount
    end

    def refund
      @afterpay_refund = Afterpay::Refund.execute(
        order_id: @afterpay_source.transaction_id,
        reference: order.number,
        payment_id: payment.number,
        amount: Money.new(amount * 100, 'AUD')
      )
    end

    def success?
      @afterpay_refund.success?
    end

  end
end
