Spree::Order.class_eval do

  # Instance methods
  def checkout_afterpay_payments
    payments.afterpay.checkout
  end

  def eligible_for_afterpay?
    # Afterpay assigns a maximum transaction amount that can be charged to every merchant
    outstanding_balance - total_applied_store_credit <= Afterpay.config.maximum_amount
  end

end
