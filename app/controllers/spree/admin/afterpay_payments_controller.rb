module Spree
  class Admin::AfterpayPaymentsController < Spree::Admin::BaseController
    before_action :load_order

    def index
      @payments = @order.payments.includes(:payment_method).where(spree_payment_methods: { type: 'Spree::Gateway::Afterpay' })
    end

    private

    def load_order
      @order = Spree::Order.find_by(number: params[:order_id])

      unless @order.present?
        redirect_to(spree.cart_path)
      end
    end
  end
end
