class TravelTimeController < ApplicationController
  def get
    # return render json: { error: "We need a valid origin in lat,long" }, status: 422 if params[:origin].blank? || params[:origin].exclude?(",")
    # return render json: { error: "We need a destination in lat,long" }, status: 422 if params[:destination].blank? || params[:destination].exclude?(",")
    params[:travel_mode] ||= "walking"

    #Need to refactor to account for failure states where lat/long is outside the boxes.

    origin = Box.intersects(params[:origin]).try(:g250m_id)
    destination = Box.intersects(params[:destination]).try(:g250m_id)
    @travel_time = TravelTime.where(g250m_id_origin: origin,
                                    g250m_id_destination: destination,
                                    travel_mode: params[:travel_mode]).first.time
    render json: @travel_time
  end
end
