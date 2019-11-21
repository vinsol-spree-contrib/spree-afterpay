class CreateSpreeAfterpayTransaction < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_afterpay_transactions do |t|
      t.references :source, index: true
      t.decimal :amount, scale: 2, precision: 8
      t.string :action
      t.string :authorization_code
      t.references :originator, polymorphic: true, index: { name: :index_spree_afterpay_transactions_on_originator }
      t.boolean :success

      t.timestamps null: false
    end
  end
end
