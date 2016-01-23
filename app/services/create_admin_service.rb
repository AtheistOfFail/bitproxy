class CreateAdminService
  def call
    user = User.find_or_create_by!(bitcoin_address: Rails.application.secrets.admin_bitcoin_address) do |user|
        user.password = Rails.application.secrets.admin_password
        user.password_confirmation = Rails.application.secrets.admin_password
        user.confirm!
      end
  end
end
