class AddRefundTypeToSpreeAfterpays < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_afterpays, :refund_type, :string
  end
end
