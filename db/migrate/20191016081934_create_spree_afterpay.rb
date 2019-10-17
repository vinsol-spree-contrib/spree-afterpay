class CreateSpreeAfterpay < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_afterpays do |t|
      t.references :payment_method, index: true
      t.references :user, index: true
      t.string :email
      # this is order token returned by afterpay
      t.string :transaction_id
      # this is datetime when order token will expire, returned by afterpay
      t.datetime :expire_at
      t.decimal :amount_allocated, precision: 8, scale: 2

      t.timestamps null: false
    end
  end
end
