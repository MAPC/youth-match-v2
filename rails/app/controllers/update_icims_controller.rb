class UpdateIcimsController < ApplicationController
  def create
    UpdateIcimsJob.perform_later
    render body: 'iCIMS will be updated'
  end
end
