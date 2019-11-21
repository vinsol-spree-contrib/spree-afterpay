module Spree
  class Afterpay < ActiveRecord::Base

    has_one :payment, class_name: 'Spree::Payment', as: :source
    belongs_to :payment_method, class_name: 'Spree::PaymentMethod', required: true

    def checkout(amount, options = {})
      afterpay_service = Spree::AfterpayRequestService.new(self, options)
      if afterpay_service.checkout
        self.amount_allocated = amount
        save!
      end
    end

  end
end
