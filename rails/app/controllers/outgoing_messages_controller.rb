class OutgoingMessagesController < ApplicationController
  before_action :set_outgoing_message, only: [:show, :edit, :update, :destroy]

  # GET /outgoing_messages
  def index
    @outgoing_messages = OutgoingMessage.all
    respond_to do |format|
      format.jsonapi { render jsonapi: @outgoing_messages }
      format.html
    end
  end

  # GET /outgoing_messages/1
  def show
    respond_to do |format|
      format.jsonapi { render jsonapi: @outgoing_message }
      format.html
    end
  end

  # GET /outgoing_messages/new
  def new
    @outgoing_message = OutgoingMessage.new
    @selected_applicant_mobile_phone_numbers = Applicant.chosen.pluck(:mobile_phone)
  end

  # POST /outgoing_messages
  def create
    @outgoing_message = OutgoingMessage.new(outgoing_message_params)

    if @outgoing_message.save
      @outgoing_message.to.each do |phone_number|
        SendTextWorker.perform_later(phone_number, @outgoing_message.body)
      end
      respond_to do |format|
        format.jsonapi { render jsonapi: 'Outgoing message was successfully created.' }
        format.html { redirect_to @outgoing_message, notice: 'Outgoing message was successfully created.' }
      end
    else
      render :new
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_outgoing_message
      @outgoing_message = OutgoingMessage.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def outgoing_message_params
      ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: [:to, :body])
    end
end
