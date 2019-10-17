module Spree
  class PaymentMethod::Afterpay < PaymentMethod
    def payment_source_class
      ::Spree::Afterpay
    end

    def can_capture?(payment)
      ['checkout', 'pending'].include?(payment.state)
    end

    def can_void?(payment)
      payment.pending?
    end

    def authorize(amount_in_cents, afterpay_source, gateway_options = {})
      if afterpay_source.nil?
        ActiveMerchant::Billing::Response.new(false, Spree.t(:unable_to_find, scope: [:afterpay_payment_method]), {}, {})
      else
        action = -> (afterpay_source) do
          afterpay_source.authorize(
            amount_in_cents / 100.0.to_d,
            currency: gateway_options[:currency],
            action_originator: gateway_options[:originator]
          )
        end
        handle_action_call(afterpay_source, action, :authorize)
      end
    end

    def capture(amount_in_cents, auth_code, gateway_options = {})
      action = -> (afterpay_source) do
        afterpay_source.capture(
          amount_in_cents / 100.0.to_d,
          auth_code,
          currency: gateway_options[:currency],
          action_originator: gateway_options[:originator]
        )
      end
      handle_action(action, :capture, auth_code)
    end

    def purchase(amount_in_cents, afterpay_source, gateway_options = {})
      event = afterpay_source.transactions.find_by(
        amount: amount_in_cents / 100.0.to_d,
        action: Spree::Afterpay::ALLOCATION_ACTION
      )

      if event.blank?
        ActiveMerchant::Billing::Response.new(false, Spree.t(:unable_to_find, scope: [:afterpay_payment_method]), {}, {})
      else
        capture(amount_in_cents, event.authorization_code, gateway_options)
      end
    end

    def void(auth_code, gateway_options = {})
      action = -> (afterpay_source) do
        afterpay_source.void(auth_code, action_originator: gateway_options[:originator])
      end
      handle_action(action, :void, auth_code)
    end

    def source_required?
      true
    end

    private

    def handle_action_call(afterpay_source, action, action_name, auth_code = nil)
      afterpay_source.with_lock do
        if response = action.call(afterpay_source)
          # note that we only need to return the auth code on an 'auth', but it's innocuous to always return
          ActiveMerchant::Billing::Response.new(
            true,
            Spree.t(:successful_action, action: action_name, scope: [:afterpay_payment_method]),
            {},
            authorization: auth_code || response
          )
        else
          ActiveMerchant::Billing::Response.new(false, afterpay_source.errors.full_messages.join, {}, {})
        end
      end
    end

    def handle_action(action, action_name, auth_code)
      # Find last event with provided auth_code
      afterpay_source = AfterpayTransaction.where(authorization_code: auth_code).last.try(:source)

      if afterpay_source.nil?
        ActiveMerchant::Billing::Response.new(
          false,
          Spree.t(:unable_to_find_for_action, auth_code: auth_code, action: action_name, scope: [:afterpay_payment_method]),
          {},
          {}
        )
      else
        handle_action_call(afterpay_source, action, action_name, auth_code)
      end
    end
  end
end
