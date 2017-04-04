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
    @pick = Pick.new(pick_params)
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
