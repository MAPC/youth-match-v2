class UpdateIcimsController < ApplicationController
  def create
    UpdateIcimsJob.perform_later
  end
end
