class VisitorsController < ApplicationController
	def complete_registration
		if current_user.bitpay_invoices.find_by_name("sign_up") == nil
			create_invoice
		end

		tx_id = current_user.bitpay_invoices.find_by_name("sign_up")
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

 	def dashboard
 		if user_signed_in?
 			@personal_downloads = current_user.downloads
 		end
 		@public_downloads = Download.where({user_id: nil}).limit(10)
 	end

 	def download
 		@input_file = params["file"]
 		@returned_file = save_to_tempfile(@input_file)
 		@opened_file = TorrentFile.open @returned_file
 		@output_hash = @opened_file.to_h

 		if @output_hash["info"]["length"]
 			@size = @output_hash["info"]["length"]
 		else
 			@size = 0
 			@output_hash["info"]["files"].each { |targ| @size += targ["length"]}
 		end
 		@size = @size / 1000000000.0 
 		@name = @output_hash["info"]["name"]

 		if user_signed_in? && current_user.bitpay_invoices
 			@user_purchase = current_user.bitpay_invoices.find_by_name(@name)
 			if @user_purchase && @user_purchase.paid
 				redirect_to dashboard_path
 				return
 			end
 		else
 			@public_purchase = BitpayInvoice.find_by_name(@name)
 			if @public_purchase && @public_purchase.paid
 				redirect_to dashboard_path
 				return
 			end
 		end

 		if user_signed_in?
 			@total_price = (0.03 + 0.09) * @size
 		else
 			@total_price = (0.025) + (0.03 + 0.09) * @size
 		end
 		@total_price = @total_price.round(2)

 		if BitpayInvoice.find_by_name(@name)
 			tx_id = BitpayInvoice.find_by_name(@name)
 			response = HTTParty.get("https://test.bitpay.com/invoices/#{tx_id.bitpay_invoice}")
			body = JSON.parse(response.body)

			if body["error"] || body["data"]["status"] == "expired"
				tx_id.destroy
				dl = Download.find_by_name(@name).destroy
				create_payment(@total_price, @name, params["file"])	
			elsif body["data"]["status"] == "complete" || body["data"]["status"] == "confirmed"
				dl = Download.find_by_name(@name)
				tx_id.paid = true
				dl.status = "Beginning download"
				tx_id.save
				dl.save
				trigger_download(dl)
			end
 		else
 			create_payment(@total_price, @name, params["file"])	
 		end
 	end

 	def trigger_download(dl)
 		dl.status = "Downloading"
 		dl.save

 		directory = Dir.mkdir(Rails.public_path + '/' + Digest::MD5.hexdigest(dl.name))
 		bt = RubyTorrent::BitTorrent.new(filename, directory)
 		thread = Thread.new do
  		until bt.complete?
    		puts "#{bt.percent_completed}% done"
    		sleep 5
  		end
		end
		bt.on_event(self, :complete) { complete_download(dl) }
 	end

 	def complete_download(dl)
 		dl.downloaded_at = Time.now
 		dl.status = "Downloaded"
 		dl.save
 	end
 	
 	def save_to_tempfile(url)
  	uri = URI.parse(url)
  	Net::HTTP.start(uri.host, uri.port) do |http|
    	resp = http.get(uri.path)
   	 	file = Tempfile.new(['temp','.torrent'], Dir.tmpdir)
    	file.binmode
    	file.write(resp.body)
    	file.flush
    	file
  	end
	end

	def create_payment(total_price, name, url)
		response = HTTParty.post("https://test.bitpay.com/invoices", body: {"token" => "5F4A71wnHnMAZd69Gs7TJHzEEQsxyBL3RsVEtbgpGYs2", "price" => total_price, "currency" => "USD", "transactionSpeed" => "high"})
    body = JSON.parse(response.body)
    
    if user_signed_in?
    	invoice = BitpayInvoice.create(user_id: current_user.id, bitpay_invoice: body["data"]["id"], name: name)
			download = Download.create(user_id: current_user.id, torrent_url: url, name: name, status: "Awaiting payment")
		else
			invoice = BitpayInvoice.create(bitpay_invoice: body["data"]["id"], name: name)
			download = Download.create(torrent_url: url, name: name, status: "Awaiting payment")
		end

    invoice.save
    download.save
	end

 	def create_invoice
 		response = HTTParty.post("https://test.bitpay.com/invoices", body: {"token" => "5F4A71wnHnMAZd69Gs7TJHzEEQsxyBL3RsVEtbgpGYs2", "price" => "0.25", "currency" => "USD", "transactionSpeed" => "high"})
    body = JSON.parse(response.body)
    invoice = BitpayInvoice.create(user_id: current_user.id, bitpay_invoice: body["data"]["id"], name: "sign_up")
    invoice.save
 	end
end
