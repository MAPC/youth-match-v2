class ApplicationController < ActionController::Base
  before_action :authenticate_user_from_token!
  before_action :authenticate_from_params!
  before_action :authenticate_user!

  def authenticate_user_from_token!
    authenticate_with_http_token do |token, options|
      user_email = options[:email].presence
      user = user_email && User.find_by_email(user_email)

      if user && Devise.secure_compare(user.authentication_token, token)
        sign_in user, store: false
      end
    end
  end

  def authenticate_from_params!
    user_email = params[:email].presence
    user = user_email && User.find_by_email(user_email)

    if user && Devise.secure_compare(user.authentication_token, params[:token])
      sign_in user, store: false
    end
  end
end
