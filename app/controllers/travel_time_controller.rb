class TravelTimeController < ApplicationController
  def get
    begin
      params[:travel_mode] ||= "walking"

      origin = Box.intersects(params[:origin]).try(:g250m_id)
      destination = Box.intersects(params[:destination]).try(:g250m_id)
      @travel_time = TravelTime.where(g250m_id_origin: origin,
                                      g250m_id_destination: destination,
                                      travel_mode: params[:travel_mode]).first.time
      render json: @travel_time
    rescue
      render json: { error: "We need a valid origin in lat,long" }, status: 422
    end
  end
end
