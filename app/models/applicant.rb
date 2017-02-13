class Applicant < ApplicationRecord
  before_validation :compute_grid_id, if: 'location.present?'

  def self.assign_lottery_numbers
    self.order("RANDOM()").each_with_index do |applicant, index|
      applicant.lottery_number = index
      applicant.save!
    end
  end

  private

  def compute_grid_id
    grid = Box.intersects(location: location)
    self.grid_id = grid.g250m_id if grid
  end
end
