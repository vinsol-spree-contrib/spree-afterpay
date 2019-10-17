Spree::Payment.class_eval do

  #Scopes
  scope :afterpay, -> { joins(:payment_method).where(spree_payment_methods: { type: Spree::PaymentMethod::Afterpay.to_s }) }
  scope :non_afterpay, -> { joins(:payment_method).where.not(spree_payment_methods: { type: Spree::PaymentMethod::Afterpay.to_s }) }

  # State Machine Transitions
  state_machine.after_transition to: :invalid, do: :cancel_afterpay_payment, if: :payment_method_afterpay?

  delegate :afterpay?, to: :payment_method, prefix: true, allow_nil: true

  # Instance Methods
  def cancel_afterpay_payment
    if source.transaction_id && source.cancelable?
      source.transactions.create!(action: Spree::Afterpay::VOID_ACTION, amount: source.amount_allocated)
    end
  end

  def pending_afterpay_approval?
    payment_method_afterpay? && source.try(:pending?)
  end

end
