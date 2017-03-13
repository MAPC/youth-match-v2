class ImportPositionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def create
    ImportPositionsJob.perform_now
    render body: 'Positions will be imported from ICIMs'
  end
end
