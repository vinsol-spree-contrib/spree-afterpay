module Spree
  class AfterpayTransaction < Spree::Base
    belongs_to :source, class_name: "Spree::Afterpay", required: true
    belongs_to :originator, polymorphic: true

    validates :action, :amount, presence: true
    validates :amount, numericality: { greater_than: 0 }, allow_blank: true
  end
end
