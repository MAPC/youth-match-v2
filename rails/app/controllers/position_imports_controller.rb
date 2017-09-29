class PositionImportsController < ApplicationController
  def create
    ImportPositionsJob.perform_later
    render body: 'Positions will be imported from ICIMs'
  end
end
