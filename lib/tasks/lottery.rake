namespace :lottery do
  desc 'Build the preference lists'
  task build_preference_lists: :environment do
    start_time = Time.now
    # update_lottery_activated_status
    BuildPreferenceListsJob.perform_later
    puts "Time to run in seconds: #{Time.now - start_time}"
  end

  desc 'Assign lottery numbers'
  task assign_lottery_numbers: :environment do
    Applicant.order("RANDOM()").each_with_index do |applicant, index|
      applicant.lottery_number = index
      # update_applicant_to_lottery_activated(applicant) if status_is_new_submission?(applicant)
      applicant.save!
    end
  end

  desc 'Match the applicants to their jobs'
  task match: :environment do
    match_applicants_to_positions
  end

  desc 'Print match results'
  task print: :environment do
    Applicant.chosen.each do |applicant|
      preference = Preference.find_by(applicant: applicant, position: applicant.offer.position)
      puts "Applicant ICIMS ID: #{applicant.icims_id}, Applicant: #{applicant.email}, Position ICIMS ID: #{applicant.offer.position.icims_id}, Position Title: #{applicant.offer.position.title}, Score: #{preference.score}, Travel Time Score: #{preference.travel_time_score}, Applicant Interests: #{applicant.interests}, Open Positions: #{applicant.offer.position.open_positions}, Prefers Nearby: #{applicant.prefers_nearby}"
    end
  end

  desc 'Update status of applicants to lottery activated'
  task update_lottery_activated_candidates: :environment do
    Applicant.all.each do |applicant|
      UpdateLotteryActivatedCandidatesJob.perform_later(applicant)
    end
  end

  desc 'Update status of candidates that accepted their job offers'
  task update_accepted_candidates: :environment do
    # Need to constrain this to acceptors from this run only in future
    Offer.where(accepted: 'yes').each do |offer|
      update_applicant_to_placement_accepted(offer.applicant)
      associate_applicant_with_position(offer.applicant_id, offer.position_id)
    end
  end

  desc 'Update status of candidates that declined their job offers'
  task update_declined_candidates: :environment do
    Offer.where(accepted: 'no_bottom_waitlist').each do |offer|
      update_applicant_to_lottery_waitlist(offer.applicant)
    end
  end

  desc 'Update status of candidates that failed to respond to job offers'
  task update_expired_candidates: :environment do
    Offer.where(accepted: 'waiting').each do |offer|
      offer.update(accepted: 'expired')
      update_applicant_to_lottery_expired(offer.applicant)
    end
  end

  desc 'Update status of chosen candidates for this round'
  task update_matched_candidates: :environment do
    Applicant.chosen.each do |applicant|
      update_applicant_to_lottery_placed(applicant)
    end
  end

  private

  def travel_time_score(applicant, position)
    minutes = travel_time(applicant, position) / 60
    applicant.prefers_nearby? ? care(minutes) : dont_care(minutes)
  end

  def travel_time(applicant, position)
    return TravelTime.find_by(
      input_id:     applicant.grid_id,
      target_id:    position.grid_id,
      travel_mode:  applicant.has_transit_pass ? "transit" : "walking"
    ).time
  rescue NoMethodError
    40.minutes.to_i
  end

  def care(minutes)
    minutes < 30 ? (0.008 * (minutes ** 2)) - (0.5833 * minutes) + 5 : -5
  end

  def dont_care(minutes)
    minutes < 40 ? (-0.25 * minutes) + 5 : -5
  end

  def interest_score(applicant, position)
    magnitude = applicant.prefers_interest? ? 5 : 3
    matches = (applicant.interests & [position.category]).any? ? 1 : -1
    return magnitude * matches
  end

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

  def update_applicant_to_lottery_activated(applicant)
    Rails.logger.info "Updating Applicant iCIMS ID #{applicant.icims_id} to lottery activated: #{applicant.id}"
    response = Faraday.patch do |req|
      req.url 'https://api.icims.com/customers/6405/applicantworkflows/' + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"C38354"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    unless response.success?
      Rails.logger.error 'ICIMS Update Status to Lottery Activated Failed for: ' + applicant.id.to_s
      Rails.logger.error 'Status: ' + response.status.to_s + ' Body: ' + response.body
    end
  end

  def status_is_new_submission?(applicant)
    response = icims_get(object: 'applicantworkflows', id: applicant.workflow_id)
    Rails.logger.info response['status']['id'].to_s
    response['status']['id'] == 'D10100' ? true : false
  end

  def status_is_lottery_activated?(applicant)
    response = icims_get(object: 'applicantworkflows', id: applicant.workflow_id)
    Rails.logger.info response['status']['id'].to_s
    response['status']['id'] == 'C38354' ? true : false
  end

  def update_applicant_to_lottery_placed(applicant)
    Rails.logger.info "Updating Applicant iCIMS ID #{applicant.icims_id} to lottery placed: #{applicant.id}"
    sleep 1
    begin
    response = Faraday.patch do |req|
      req.url 'https://api.icims.com/customers/6405/applicantworkflows/' + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"C38356"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
      req.options.timeout = 60
      req.options.open_timeout = 60
    end
    rescue Faraday::Error::ConnectionFailed => e
      Rails.logger.error "Connection failed: #{e}"
    end
    unless response.blank? || response.success?
      Rails.logger.error 'ICIMS Update Status to Lottery Placed Failed for: ' + applicant.id.to_s
      Rails.logger.error 'Status: ' + response.status.to_s + ' Body: ' + response.body
    end
  end

  def update_applicant_to_placement_accepted(applicant)
    Rails.logger.info "Updating Applicant iCIMS ID #{applicant.icims_id} to placement accepted: #{applicant.id}"
    response = Faraday.patch do |req|
      req.url 'https://api.icims.com/customers/6405/applicantworkflows/' + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"C36951"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
      req.options.timeout = 90
      req.options.open_timeout = 90
    end
    unless response.success?
      Rails.logger.error 'ICIMS Update Status to Lottery Placement Accepted Failed for: ' + applicant.id.to_s
      Rails.logger.error 'Status: ' + response.status.to_s + ' Body: ' + response.body
    end
  end

  def update_applicant_to_lottery_waitlist(applicant)
    Rails.logger.info "Updating Applicant iCIMS ID #{applicant.icims_id} to lottery waitlist: #{applicant.id}"
    response = Faraday.patch do |req|
      req.url 'https://api.icims.com/customers/6405/applicantworkflows/' + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"C51162"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
      req.options.timeout = 90
      req.options.open_timeout = 90
    end
    unless response.success?
      Rails.logger.error 'ICIMS Update Status to Lottery Waitlist Failed for: ' + applicant.id.to_s
      Rails.logger.error 'Status: ' + response.status.to_s + ' Body: ' + response.body
    end
  end

  def update_applicant_to_lottery_expired(applicant)
    Rails.logger.info "Updating Applicant iCIMS ID #{applicant.icims_id} to lottery expired: #{applicant.id}"
    sleep 1
    begin
    response = Faraday.patch do |req|
      req.url 'https://api.icims.com/customers/6405/applicantworkflows/' + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"C38355"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
      req.options.timeout = 90
      req.options.open_timeout = 90
    end
    rescue Faraday::Error::ConnectionFailed => e
      Rails.logger.error "Connection failed: #{e}"
    end
    unless response.blank? || response.success?
      Rails.logger.error 'ICIMS Update Status to Lottery Expired Failed for: ' + applicant.id.to_s
      Rails.logger.error 'Status: ' + response.status.to_s + ' Body: ' + response.body
    end
  end

  def associate_applicant_with_position(applicant_id, position_id)
    applicant = Applicant.find(applicant_id)
    position = Position.find(position_id)
    Rails.logger.info "Associate applicant iCIMS ID #{applicant.icims_id} with position: #{applicant.id}"
    response = Faraday.post do |req|
      req.url 'https://api.icims.com/customers/6405/applicantworkflows'
      req.body = %Q{ {"baseprofile":#{position.icims_id},"status":{"id":"C36951"},"associatedprofile":#{applicant.icims_id}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
      req.options.timeout = 90
      req.options.open_timeout = 90
    end
    unless response.success?
      Rails.logger.error 'ICIMS Associate Applicant with Position Failed for: ' + applicant.id.to_s
      Rails.logger.error 'Status: ' + response.status.to_s + ' Body: ' + response.body
    end
  end

  def icims_get(object:, fields: '', id:)
    response = Faraday.get("https://api.icims.com/customers/6405/#{object}/#{id}",
                           { fields: fields },
                           authorization: "Basic #{Rails.application.secrets.icims_authorization_key}")
    JSON.parse(response.body)
  end

  def update_lottery_activated_status
    Applicant.all.each do |applicant|
      if status_is_lottery_activated?(applicant)
        applicant.update(lottery_activated: true)
      else
        applicant.update(lottery_activated: false)
      end
    end
  end
end
