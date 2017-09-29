class PicksController < ApplicationController
  def index
    @picks = []
    current_user.positions.each do |position|
      position.picks.each do |pick|
        @picks << pick
      end
    end
    respond_to do |format|
      format.jsonapi { render jsonapi: @picks }
    end
  end

  def show
    @picks = Pick.find(params[:id])
    respond_to do |format|
      format.jsonapi { render jsonapi: @picks }
    end
  end

  def create
    @pick = Pick.create(pick_params)
    respond_to do |format|
      if @pick.save
        format.jsonapi { render jsonapi: @pick }
      else
        format.jsonapi { render jsonapi: @pick.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @pick = Pick.find(params[:id])
    @pick.destroy
    respond_to do |format|
      format.jsonapi { head :no_content }
    end
  end

  def update
    @pick = Pick.find(params[:id])
    if @pick.update_attributes(pick_params)
      respond_to do |format|
        format.jsonapi { render jsonapi: @pick }
      end
    else
      head :forbidden
    end
  end

  private

  def pick_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params)
  end
end
