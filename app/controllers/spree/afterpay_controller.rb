module Spree
  class AfterpayController < StoreController

    SUCCESS_STATUS = 'SUCCESS'.freeze
    CANCELLED_STATUS = 'CANCELLED'.freeze

    before_action :load_order, only: [:cancel, :success]
    before_action :validate_token, only: [:cancel, :success]
    before_action :validate_success_status, only: [:success]

    def checkout
      @order = current_order || raise(ActiveRecord::RecordNotFound)
      @order.checkout_afterpay_payments.map(&:invalidate!)
      create_afterpay_payment

      afterpay_source = @order.checkout_afterpay_payments.last.try(:source)
      if afterpay_source && afterpay_source.checkout(@order.outstanding_balance - @order.total_applied_store_credit, currency: current_currency, auto_capture: true)
        # Set the completed_at field of the current order, so that it is no longer shown to the user in the current session
        @order.update_columns(completed_at: Time.current, special_instructions: Spree.t(:order_marked_paid_info, scope: :afterpay, time: Time.current, number: @order.number))
        @token = afterpay_source.token
        render partial: "spree/checkout/initialize_afterpay"
      else
        flash[:error] = Spree.t(:unable_to_checkout, scope: [:afterpay_payment_method])
        redirect_to checkout_state_path(@order.state)
      end
    end

    def success
      reset_order
      complete_order(Spree.t(:order_processed_successfully))
    end

    def cancel
      reset_order
      invalidate_afterpay_payment
      if params[:status] && params[:status] == CANCELLED_STATUS
        flash[:error] = Spree.t(:payment_cancelled, scope: [:afterpay])
      else
        flash[:error] = Spree.t(:payment_failed, scope: [:afterpay])
      end
      redirect_to checkout_state_path(@order.state)
    end

    private

    def create_afterpay_payment
      @order.payments.create!({
        source: Spree::Afterpay.create({
          payment_method_id: params[:payment_method_id]
        }),
        amount: @order.total,
        state: 'checkout',
        payment_method: payment_method,
      })
    end

    def payment_method
      @payment_method ||= Spree::PaymentMethod.find(params[:payment_method_id])
    end

    def validate_token
      sanitized_token = params[:orderToken]
      unless sanitized_token == @order.payments&.afterpay.last&.source&.token
        redirect_to(spree.cart_path)
      end
    end

    def validate_success_status
      unless params[:status] && params[:status] == SUCCESS_STATUS
        flash[:error] = Spree.t(:payment_failed, scope: [:afterpay])
        redirect_to checkout_state_path(@order.state)
      end
    end

    def reset_order
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
        flash[:error] = @order.errors.full_messages.join('\n')
        redirect_to(checkout_state_path(@order.state)) && return
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
