class RehireSitesController < ApplicationController
  def get_uniq_sites
    @sites = RehireSite.all.uniq { |r| r.site_name }.pluck(:site_name)
    render json: @sites
  end

  def index
    @sites = RehireSite.with_applicant_data.where(filter_params[:filter])
    respond_to do |format|
      format.jsonapi { render jsonapi: @sites }
    end
  end

  def update
    @person = RehireSite.find(safe_params[:id])
    puts safe_params
    @person.update_attributes(safe_params)
    @person.save!
  end

  private

  def filter_params
    params.permit!
  end

  def safe_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params)
  end
end
