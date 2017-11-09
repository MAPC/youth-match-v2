class OffersController < ApplicationController
  before_action :set_offer, only: [:show, :edit, :update, :destroy]

  # GET /offers
  # GET /offers.json
  def index
    if params[:for_applicant]
      @offers = current_user.applicant.offers
    elsif params[:for_positions]
      @offers = []
      current_user.positions.each { |offer| @offers << offer }
    else
      @offers = Offer.all
    end

    respond_to do |format|
      format.jsonapi { render jsonapi: @offers }
    end
  end

  # GET /offers/1
  # GET /offers/1.json
  def show
  end

  # GET /offers/new
  def new
    @offer = Offer.new
  end

  # GET /offers/1/edit
  def edit
  end

  # GET /offers/answer
  def answer
    @offer = current_user.applicant.offers.order(:created_at).last
    if params[:response]
      if current_user.applicant.lottery_activated?
        @offer.update(accepted: 'yes')
      else
        render head: :gone
      end
    else
      if current_user.applicant.lottery_activated?
        @offer.update(accepted: 'no_bottom_waitlist')
      else
        render head: :gone
      end
    end
  end

  # POST /offers
  # POST /offers.json
  def create
    @offer = Offer.new(offers_params)

    respond_to do |format|
      if @offer.save
        format.jsonapi { render jsonapi: @offer, status: :created }
      else
        format.jsonapi { render jsonapi: @offer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /offers/1
  # PATCH/PUT /offers/1.json
  def update
    respond_to do |format|
      if @offer.update(offers_params)
        format.jsonapi { render :show, status: :ok, location: @offer }
      else
        format.jsonapi { render jsonapi: @offer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /offers/1
  # DELETE /offers/1.json
  def destroy
    @offer.destroy
    respond_to do |format|
      format.jsonapi { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_offer
      @offer = Offer.find(params[:id])
    end

    def offers_params
      ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: [:applicant, :position, :accepted])
    end

end
