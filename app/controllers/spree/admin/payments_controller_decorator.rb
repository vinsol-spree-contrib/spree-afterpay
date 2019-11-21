module Spree::Admin::PaymentsControllerDecorator
  def afterpay_refund
    if @payment.source.state == 'refunded'
      flash[:error] = Spree.t(:already_refunded, scope: 'afterpay')
      redirect_to admin_order_payment_path(@order, @payment)
    end
  end

  def execute_afterpay_refund
    response = @payment.payment_method.refund(@payment, params[:refund_amount].to_f)

    if response.success?
      flash[:success] = Spree.t(:refund_successful, scope: 'afterpay')
      redirect_to admin_order_payments_path(@order)
    else
      flash.now[:error] = Spree.t(:refund_unsuccessful, scope: 'afterpay')
      render 'afterpay_refund'
    end
  end

end

Spree::Admin::PaymentsController.prepend Spree::Admin::PaymentsControllerDecorator
