module Spree
  class Gateway::Afterpay < Gateway

    def supports?(source)
      true
    end

    def auto_capture?
      true
    end

    def method_type
      'afterpay'
    end

    def provider_class
      Spree::AfterpayApi::Payment
    end

    def purchase(amount, afterpay_source, gateway_options={})
      return false unless afterpay_source.token.present?

      afterpay_service = Spree::AfterpayService.new(afterpay_source, gateway_options)
      if afterpay_service.capture
        # We need to store the transaction id for the future.
        # This is mainly so we can use it later on to refund the payment if the user wishes.
        transaction_id = afterpay_service.payment_request.transaction_id
        afterpay_source.payment.update_columns(response_code: transaction_id)
        afterpay_source.update_columns(transaction_id: transaction_id)
        # This is rather hackish, required for payment/processing handle_response code.
        Class.new do
          def success?; true; end
          def authorization; nil; end
        end.new
      else
        Class.new do
          def success?; false; end
          def to_s; Spree.t(:unable_to_capture, scope: [:afterpay_payment_method]); end
        end.new
      end
    end

    def refund(payment, amount)
      return false if payment.nil? || amount <= 0.0 || amount > payment.amount

      refund_type = payment.amount == amount ? "Full" : "Partial"

      afterpay_service = Spree::AfterpayService.new(payment.source, amount: amount)
      refund_transaction_response = afterpay_service.refund
      if refund_transaction_response.success?
        payment.source.update_columns({
          refunded_at: Time.now,
          refund_transaction_id: refund_transaction_response.refund_id,
          state: "refunded",
          refund_type: refund_type
        })

        payment.class.create!(
          order: payment.order,
          source: payment,
          payment_method: payment.payment_method,
          amount: amount.abs * -1,
          response_code: refund_transaction_response.refund_id,
          state: 'completed'
        )
        refund_transaction_response
      end
    end
  end
end
