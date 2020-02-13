Spree::Payment.class_eval do

  #Scopes
  scope :afterpay, -> { joins(:payment_method).where(spree_payment_methods: { type: Spree::Gateway::Afterpay.to_s }) }

end
