class Position < ApplicationRecord
  before_validation :compute_grid_id, if: 'location.present?'
  has_many :preferences
  has_many :requisitions
  has_many :applicants, through: :requisitions
  has_many :selections, through: :picks, source: :applicants
  has_many :picks
  has_many :users, through: :sites
  has_many :sites
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
