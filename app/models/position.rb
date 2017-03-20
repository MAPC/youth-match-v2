class Position < ApplicationRecord
  before_validation :compute_grid_id, if: 'location.present?'
  has_many :preferences
  has_and_belongs_to_many :applicants
  has_one :offer

  def open?
    offer.blank?
  end

  def prefers?(new_applicant)
    # return true if the new_applicant has a higher score relative to this position than if the
    # current applicant assigned to the position.
    preferences.find_by(applicant: new_applicant).score >
    preferences.find_by(applicant: self.offer.applicant).score
  end

  private

  def compute_grid_id
    grid = Box.intersects(location: location)
    self.grid_id = grid.g250m_id if grid
  end
end
