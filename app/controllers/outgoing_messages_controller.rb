class OutgoingMessagesController < ApplicationController
  before_action :set_outgoing_message, only: [:show, :edit, :update, :destroy]

  # GET /outgoing_messages
  def index
    @outgoing_messages = OutgoingMessage.all
  end

  # GET /outgoing_messages/1
  def show
  end

  # GET /outgoing_messages/new
  def new
    @outgoing_message = OutgoingMessage.new
  end

  # GET /outgoing_messages/1/edit
  def edit
  end

  # POST /outgoing_messages
  def create
    @outgoing_message = OutgoingMessage.new(outgoing_message_params)

    if @outgoing_message.save
      redirect_to @outgoing_message, notice: 'Outgoing message was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /outgoing_messages/1
  def update
    if @outgoing_message.update(outgoing_message_params)
      redirect_to @outgoing_message, notice: 'Outgoing message was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /outgoing_messages/1
  def destroy
    @outgoing_message.destroy
    redirect_to outgoing_messages_url, notice: 'Outgoing message was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_outgoing_message
      @outgoing_message = OutgoingMessage.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def outgoing_message_params
      params.require(:outgoing_message).permit(:body, to: [])
    end
end
