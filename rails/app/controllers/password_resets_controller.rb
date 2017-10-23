class PasswordResetsController < ApplicationController
  def create
    if current_user.account_type == 'staff'
      password = Devise.friendly_token.first(8)
      user = User.find_by_id(password_reset_params[:user_id])
      if user.try(:reset_password, password, password)
        ApplicantMailer.job_picker_email(user).deliver_later
        respond_to do |format|
          format.jsonapi { render jsonapi: 'Check your email for your new password.' }
          format.html { redirect_to @outgoing_message, notice: 'Check your email for your new password.' }
        end
      else
        respond_to do |format|
          format.jsonapi { render jsonapi: 'Password reset failed because user does not exist.', status: :internal_server_error }
        end
      end
    else
      respond_to do |format|
        format.jsonapi { render jsonapi: 'Password reset failed because you do not have sufficient permissions.', status: :internal_server_error }
      end
    end
  end

  private

  def password_reset_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: [:user_id])
  end
end
