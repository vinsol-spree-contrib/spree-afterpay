module Spree
  class Afterpay < Spree::Base

    ALLOCATION_ACTION = 'allocation'.freeze
    AUTHORIZE_ACTION  = 'authorize'.freeze
    CAPTURE_ACTION    = 'capture'.freeze
    VOID_ACTION       = 'void'.freeze

    has_many :transactions, class_name: 'Spree::AfterpayTransaction', foreign_key: :source_id, dependent: :destroy
    has_one :payment, class_name: 'Spree::Payment', as: :source
    belongs_to :payment_method, class_name: "Spree::PaymentMethod", required: true
    belongs_to :user, class_name: Spree.user_class.to_s

    validates :email, presence: true
    validates :amount_allocated, numericality: { greater_than: 0 }, allow_blank: true

    def checkout(amount, options = {})
      afterpay_service = Spree::AfterpayService.new(self, options)
      if afterpay_service.checkout
        transactions.build(
          action: ALLOCATION_ACTION,
          amount: amount,
          originator: options[:action_originator],
          success: true,
          authorization_code: transaction_id
        )
        self.amount_allocated = amount
        save!
      end
    end

    def authorize(amount, options = {})
      authorization_code = options[:action_authorization_code]
      if authorization_code
        if transactions.find_by(action: AUTHORIZE_ACTION, amount: amount, authorization_code: authorization_code, success: true)
          return true
        end
      else
        authorization_code = transaction_id
      end

      if allocated?(amount)
        transactions.create!(
          action: AUTHORIZE_ACTION,
          amount: amount,
          originator: options[:action_originator],
          authorization_code: authorization_code
        )
        authorization_code
      else
        errors.add(:base, Spree.t(:no_amount_allocation, scope: [:afterpay_payment_method]))
        false
      end
    end

    def allocated?(amount)
      transactions.find_by(action: ALLOCATION_ACTION, amount: amount, success: true)
    end

    def capture(amount, authorization_code, options = {})
      return false unless authorize(amount, action_authorization_code: authorization_code)

      afterpay_service = Spree::AfterpayService.new(self, options)
      if afterpay_service.capture
        transactions.create!(
          action: CAPTURE_ACTION,
          amount: amount,
          originator: options[:action_originator]
        )
        transaction_id
      else
        errors.add(:base, Spree.t(:unable_to_capture, scope: [:afterpay_payment_method], auth_code: authorization_code))
        false
      end
    end

    def void(authorization_code, options = {})
      auth_transaction = transactions.find_by(action: AUTHORIZE_ACTION, authorization_code: authorization_code)
      if auth_transaction
        amount = auth_transaction.amount
        transactions.create!(
          action: VOID_ACTION,
          amount: amount,
          originator: options[:action_originator]
        )
        true
      else
        errors.add(:base, Spree.t(:unable_to_void, scope: [:afterpay_payment_method], auth_code: authorization_code))
        false
      end
    end

    def cancelable?
      authorized? || captured?
    end

    def authorized?
      transactions.find_by(action: AUTHORIZE_ACTION)
    end

    def captured?
      transactions.find_by(action: CAPTURE_ACTION)
    end

    def actions
      [CAPTURE_ACTION, VOID_ACTION]
    end

    def can_void?(payment)
      payment.pending?
    end

    def can_capture?(payment)
      ['checkout', 'pending'].include?(payment.state)
    end
  end
end
