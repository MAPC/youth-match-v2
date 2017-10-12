class UsersController < ApplicationController

  skip_before_action :authenticate_user_from_token!
  skip_before_action :authenticate_from_params!
  skip_before_action :authenticate_user!


  def create
    user_params = params[:data][:attributes]

    @user = User.create({
      email: user_params[:email],
      password: user_params[:password],
    })

    respond_to do |format|
      format.jsonapi { render jsonapi: @user }
    end
  end


  def update
    if current_user.account_type == 'staff'
      @user = User.find(params[:id])

      if @user.update(user_params)
        respond_to do |format|
          format.jsonapi { render jsonapi: @user }
        end
      end
    else
      header :unauthorized
    end
  end


  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.jsonapi { render jsonapi: @user }
    end
  end


  def index
    if params[:email]
      @users = User.where(email: params[:email])
    else
      @users = User.all
    end

    respond_to do |format|
      format.jsonapi { render jsonapi: @users }
    end
  end


  private

    def user_params
      params.require(:user).permit(:password, :account_type)
    end

end
