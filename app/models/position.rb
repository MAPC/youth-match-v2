class Position < ApplicationRecord
  before_validation :compute_grid_id, if: 'location.present?'
  has_many :preferences
  belongs_to :applicant

  def open?
    applicant.blank?
  end

  def prefers?(new_applicant)
    # return true if the new_applicant has a higher score relative to this position than if the
    # current applicant assigned to the position
    preferences.where(applicant: new_applicant).first.score >
    preferences.where(applicant: self.applicant).first.score
  end

  private

  def compute_grid_id
    grid = Box.intersects(location: location)
    self.grid_id = grid.g250m_id if grid
  end
end
