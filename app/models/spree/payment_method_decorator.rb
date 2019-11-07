Spree::PaymentMethod.class_eval do

  # Scopes
  scope :afterpay, -> { where(type: "Spree::Gateway::Afterpay") }

  # Instance Methods
  def afterpay?
    type == "Spree::Gateway::Afterpay"
  end

end
