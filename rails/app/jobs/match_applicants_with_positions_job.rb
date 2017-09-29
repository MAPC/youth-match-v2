class MatchApplicantsWithPositionsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    match_applicants_to_positions
  end

  private

  def match_applicants_to_positions
    Applicant.chosen.each do |applicant|
      applicant.match_to_position
    end

    # We match applicants to jobs. Now some applicants were placed then got knocked out by a better match.
    # These applicants still need to appropriately match.

    # Applicant.chosen where no offers exist then we need to keep matching
    # Do not match if there are no open positions
    # How to know if open_positions?
    # Take the sum of open_positions and then subtract the number of waiting offers
    # set open positions to open_positions from icims minus workflows from icims so we're always sync'd
    if Position.all.sum(:open_positions) > Offer.where(accepted: 'waiting').count # or Offer.where(accepted: 'waiting').count == Applicant.chosen.count
      match_applicants_to_positions
    end

    # if there are any open positions, then run match applicants to positions
    # Position count of associated offers is less than integer open_positions.
    # Issues: exempt picks need to be subtracted in or outside icims
    # Need to subtract accepted offers
    # Just accept open positions minus number of currently associated applicants as my open_positions number
    # then subtract offers as we generate them in my app. But how do we avoid double counting offers?
    # Only subtract "waiting" offers

    #we need to set offer status to expired for applicants that do not answer the call so that we have no waiting offers during the lottery
  end
end
