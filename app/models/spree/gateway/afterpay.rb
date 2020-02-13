module Spree
  class Gateway::Afterpay < Gateway

    def supports?(source)
      true
    end

    def available_for_order?(order)
      order.eligible_for_afterpay?
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

      afterpay_service = Spree::AfterpayRequestService.new(afterpay_source, gateway_options)
      afterpay_service.capture
      afterpay_response = Spree::AfterpayResponseService.new(afterpay_service)
      if afterpay_response.captured?
        # We need to store the transaction id for the future.
        # This is mainly so we can use it later on to refund the payment if the user wishes.
        transaction_id = afterpay_response.transaction_id
        afterpay_source.payment.update_columns(response_code: transaction_id)
        afterpay_source.update_columns(transaction_id: transaction_id)
      end
      afterpay_response
    end

    def refund(payment, amount, refund_reason_id = nil)
      return false if payment.nil? || amount <= 0.0 || amount > payment.amount

      refund_type = payment.amount == amount ? 'Full' : 'Partial'
      afterpay_service = Spree::AfterpayRequestService.new(payment.source, amount: amount)
      refund_transaction_response = afterpay_service.refund

      if refund_transaction_response.success?
        payment.order.update_columns({
          payment_total: payment.amount - amount
        })

        payment.source.update_columns({
          refunded_at: Time.current,
          refund_transaction_id: refund_transaction_response.afterpay_refund.refund_id,
          state: 'refunded',
          refund_type: refund_type
        })

        payment.refunds.create!(
          amount: amount.abs,
          transaction_id: refund_transaction_response.afterpay_refund.refund_id,
          refund_reason_id: refund_reason_id || Spree::RefundReason.first.id
        )
      end
      refund_transaction_response
    end

    def credit(amount_in_cents, auth_code, gateway_options)
      payment = gateway_options[:originator].payment
      amount = amount_in_cents / 100.0.to_d
      refund_type = payment.amount == amount ? 'Full' : 'Partial'

      afterpay_request_service = Spree::AfterpayRequestService.new(payment.source, amount: amount)
      refund_transaction_response = afterpay_request_service.refund

      if refund_transaction_response.success?
        payment.order.update_columns({
          payment_total: payment.amount - amount
        })

        payment.source.update_columns({
          refunded_at: Time.current,
          refund_transaction_id: refund_transaction_response.afterpay_refund.refund_id,
          state: 'refunded',
          refund_type: refund_type
        })

        ActiveMerchant::Billing::Response.new(
          true,
          Spree.t('refund_successful', scope: :afterpay),
          {},
          authorization: refund_transaction_response.afterpay_refund.refund_id || refund_transaction_response.afterpay_refund
        )
      else
        ActiveMerchant::Billing::Response.new(false, Spree.t('refund_unsuccessful', scope: :afterpay), {}, {})
      end

    end

  end
end
