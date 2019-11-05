class CreateSpreeAfterpayCheckouts < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_afterpay_checkouts do |t|
      # this is order token returned by afterpay
      t.string :token
      # this is datetime when order token will expire, returned by afterpay
      t.datetime :expire_at
      t.string :state, default: "complete"
      # this is the unique Afterpay (merchant payment) order ID
      t.string :transaction_id, index: true
      # this is the unique Afterpay (merchant payment) refund ID
      t.string :refund_transaction_id
      t.datetime :refunded_at
      t.timestamps null: false
    end
  end
end
