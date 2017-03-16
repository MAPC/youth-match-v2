class ImportPositionsController < ApplicationController
  def create
    ImportPositionsJob.perform_now
    render body: 'Positions will be imported from ICIMs'
  end
end
