class AddRefundTypeToSpreeAfterpayCheckouts < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_afterpay_checkouts, :refund_type, :string
  end
end
