class RequisitionsController < ApplicationController
  def update
    @requisition = Requisition.find(params[:id])
    if @requisition.update_attributes(requisition_params)
      respond_to do |format|
        format.jsonapi { render jsonapi: @requisition }
      end
    else
      head :forbidden
    end
  end

  private

  def requisition_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params)
  end
end
