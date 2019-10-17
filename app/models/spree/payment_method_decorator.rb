Spree::PaymentMethod.class_eval do

  # Scopes
  scope :afterpay, -> { where(type: "Spree::PaymentMethod::Afterpay") }

  # Instance Methods
  def afterpay?
    type == "Spree::PaymentMethod::Afterpay"
  end

end
