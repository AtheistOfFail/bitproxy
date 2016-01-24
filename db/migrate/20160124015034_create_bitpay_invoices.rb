class CreateBitpayInvoices < ActiveRecord::Migration
  def change
    create_table :bitpay_invoices do |t|
      t.text :user_id
      t.text :bitpay_invoice
      t.text :reference
      t.boolean :paid, default: false

      t.timestamps null: false
    end
  end
end
