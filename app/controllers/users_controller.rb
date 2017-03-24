class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.jsonapi { render jsonapi: @user }
    end
  end

  def index
    @users = User.where(email: params[:email])
    respond_to do |format|
      format.jsonapi { render jsonapi: @users }
    end
  end
end
