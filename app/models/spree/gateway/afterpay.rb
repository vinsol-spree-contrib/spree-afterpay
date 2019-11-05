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

    def purchase(amount, afterpay_checkout, gateway_options={})
      # ToDo Use afterpay API calls here to charge user
    end

    def refund(payment, amount)
      # ToDo Use afterpay API calls here to refund order
    end
  end
end
