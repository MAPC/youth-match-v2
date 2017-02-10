class Applicant < ApplicationRecord
  before_validation :compute_grid_id, if: 'location.present?'

  private

  def compute_grid_id
    grid = Box.intersects(location: location)
    self.grid_id = grid.g250m_id if grid
  end
end
