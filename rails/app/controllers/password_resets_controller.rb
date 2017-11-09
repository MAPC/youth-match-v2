class PasswordResetsController < ApplicationController
  def create
    if current_user.account_type == 'staff'
      password = Devise.friendly_token.first(8)
      user = User.find_by_id(password_reset_params[:user_id])
      if user.try(:reset_password, password, password)
        email_password_to(user, password)
        respond_to do |format|
          format.jsonapi { render head: :created  }
          format.html { redirect_to @outgoing_message, notice: 'Check your email for your new password.' }
        end
      else
        respond_to do |format|
          format.jsonapi { render head: :bad_request }
        end
      end
    else
      respond_to do |format|
        format.jsonapi { render head: :unauthorized }
      end
    end
  end

  private

  def password_reset_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: [:user_id])
  end

  def email_password_to(user, password)
    case user.account_type
    when 'staff'
      StaffMailer.staff_login_email(user, password).deliver_later
    when 'youth'
      ApplicantMailer.job_picker_email(user).deliver_later
    when 'partner'
      CboUserMailer.cbo_user_email(user).deliver_later
    end
  end
end
