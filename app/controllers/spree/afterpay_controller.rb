module Spree
  class AfterpayController < Spree::BaseController

    before_action :load_order, only: [:cancel, :success]
    before_action :validate_token, only: [:cancel, :success]
    before_action :validate_success_status, only: [:success]
    before_action :reset_completed_at_field_of_order, only: [:cancel, :success]
    before_action :invalidate_afterpay_payment, only: [:cancel]

    def source
      # ToDo create
    end

    def success
      complete_order(Spree.t(:order_processed_successfully))
    end

    def cancel
      if params[:status] && params[:status] == 'CANCELLED'
        flash[:error] = Spree.t(:payment_cancelled, scope: [:afterpay])
      else
        flash[:error] = Spree.t(:payment_failed, scope: [:afterpay])
      end
      redirect_to checkout_state_path(@order.state)
    end

    private

    def validate_token
      sanitized_token = params[:orderToken].try(:split, '?').try(:first)
      unless sanitized_token == @order.payments&.afterpay.last&.source&.transaction_id
        redirect_to(spree.cart_path)
      end
    end

    def validate_success_status
      unless params[:status] && params[:status] == "SUCCESS"
        flash[:error] = Spree.t(:payment_failed, scope: [:afterpay])
        redirect_to checkout_state_path(@order.state)
      end
    end

    def reset_completed_at_field_of_order
      if @order.checkout_afterpay_payments.present?
        @order.update_columns(completed_at: nil)
      end
    end

    def completion_route
      spree.order_path(@order)
    end

    def load_order
      @order = Spree::Order.find_by(number: params[:id])

      unless @order.present? && @order.payment_total < @order.total
        redirect_to(spree.cart_path)
      end
    end

    def invalidate_afterpay_payment
      @order.checkout_afterpay_payments.map(&:invalidate!)
    end

    def complete_order(flash_message)
      unless @order.next
        flash[:error] = [@order.errors.full_messages.join('\n'), Spree.t(:contact_customer_service)].join(' ')
        redirect_to(checkout_state_path(@order.state))
      end

      if @order.completed?
        @current_order = nil
        flash[:notice] = flash_message
        flash[:order_completed] = true
        redirect_to completion_route
      else
        redirect_to checkout_state_path(@order.state)
      end
    end

  end
end
