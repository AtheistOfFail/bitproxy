class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :rememberable, :authentication_keys => [:bitcoin_address]
  has_one :bitpay_invoice
  def email_required?
    false
  end
end
