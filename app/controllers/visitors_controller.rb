class VisitorsController < ApplicationController
	def complete_registration
		if current_user.bitpay_invoices.find_by_reference("sign_up") == nil
			create_invoice
		end

		tx_id = current_user.bitpay_invoices.find_by_reference("sign_up")
		response = HTTParty.get("https://test.bitpay.com/invoices/#{tx_id.bitpay_invoice}")
		body = JSON.parse(response.body)
		
		if body["error"] || body["data"]["status"] == "expired"
			tx_id.destroy
 		elsif body["data"]["status"] == "confirmed"
 			tx_id.paid = true
 			current_user.active = true;
 			tx_id.save
 			current_user.save
 			redirect_to root_path
 		end
 	end

 	def create_invoice
 		response = HTTParty.post("https://test.bitpay.com/invoices", body: {"token" => "5F4A71wnHnMAZd69Gs7TJHzEEQsxyBL3RsVEtbgpGYs2", "price" => "0.25", "currency" => "USD", "transactionSpeed" => "high"})
    body = JSON.parse(response.body)
    invoice = BitpayInvoice.create(user_id: current_user.id, bitpay_invoice: body["data"]["id"], reference: "sign_up")
    current_user.bitpay_invoices = invoice
    invoice.save
 	end
end
