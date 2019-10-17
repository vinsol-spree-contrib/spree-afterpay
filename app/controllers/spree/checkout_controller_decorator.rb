module Spree::CheckoutControllerDecorator
  def self.prepended(base)
    base.before_action :checkout_afterpay_payment, only: [:update]
  end

  # Afterpay Specific Methods Start
  def checkout_afterpay_payment
    if afterpay_payment_present?
      @order.checkout_afterpay_payments.map(&:invalidate!)
      create_afterpay_payment

      # Remove other payment method parameters.
      params[:order].delete(:payments_attributes)
      params.delete(:payment_source)
      afterpay_source = @order.checkout_afterpay_payments.last.try(:source)
      if afterpay_source && afterpay_source.checkout(@order.outstanding_balance, currency: current_currency, auto_capture: true)
        # Always send `auto_capture` as true to Afterpay because we cannot send `capture` event from Spree to Afterpay.
        # Set the completed_at field of the current order, so that it is no longer shown to the user in the current session
        @order.update_columns(completed_at: Time.current, special_instructions: Spree.t(:order_marked_paid_info, scope: :afterpay, time: Time.current, number: @order.number))
        @token = afterpay_source.transaction_id
        render partial: "spree/checkout/initialize_afterpay"
      else
        flash[:error] = afterpay_source.errors.full_messages.to_sentence if afterpay_source
        redirect_to checkout_state_path(@order.state) and return
      end
    end
  end

  def create_afterpay_payment
    source_params = params.require(:payment_source).permit![afterpay_payment_method.id.to_s]
    @order.payments.create!(
      payment_method: afterpay_payment_method,
      amount: @order.outstanding_balance,
      state: 'checkout',
      source_attributes: source_params
    )
  end

  def afterpay_payment_present?
    params[:order] && params[:order][:payments_attributes] && params[:order][:payments_attributes].any? { |p| p[:payment_method_id] == afterpay_payment_method.try(:id).to_s } && @order.eligible_for_afterpay?
  end

  def afterpay_payment_method
    @afterpay_payment_method ||= Spree::PaymentMethod.afterpay.available_on_front_end.first
  end
    # Afterpay Specific Methods End
end
Spree::CheckoutController.prepend(Spree::CheckoutControllerDecorator)
