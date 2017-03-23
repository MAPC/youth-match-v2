class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.jsonapi { render jsonapi: @user }
    end
  end
end
