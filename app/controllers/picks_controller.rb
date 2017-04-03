class PicksController < ApplicationController
  def show
    @picks = Pick.find(params[:id])
    respond_to do |format|
      format.jsonapi { render jsonapi: @picks }
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
