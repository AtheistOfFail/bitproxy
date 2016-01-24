class CreateBitpayInvoices < ActiveRecord::Migration
  def change
    create_table :bitpay_invoices do |t|
      t.text :user_id
      t.text :bitpay_invoice

      t.timestamps null: false
    end
  end
end
