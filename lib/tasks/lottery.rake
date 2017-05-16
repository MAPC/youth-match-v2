namespace :lottery do
  desc 'Build the preference lists'
  task build_preference_lists: :environment do
    start_time = Time.now
    BuildPreferenceListsJob.perform_now
    puts "Time to run in seconds: #{Time.now - start_time}"
  end

  desc 'Assign lottery numbers'
  task assign_lottery_numbers: :environment do
    Applicant.order("RANDOM()").each_with_index do |applicant, index|
      applicant.lottery_number = index
      update_applicant_to_lottery_activated(applicant) if status_is_new_submission?(applicant)
      applicant.save!
    end
  end

  desc 'Match the applicants to their jobs'
  task match: :environment do
    match_applicants_to_positions
  end

  desc 'Print match results'
  task print: :environment do
    all_chosen_applicants.each do |applicant|
      preference = Preference.find_by(applicant: applicant, position: applicant.offer.position)
      puts "Applicant: #{applicant.email}, Position: #{applicant.offer.position.id} #{applicant.offer.position.title}, Score: #{preference.score}, Travel Time Score: #{preference.travel_time_score}"
    end
  end

  desc 'Update status of candidates that accepted their job offers'
  task update_accepted_candidates: :environment do
    # Need to constrain this to acceptors from this run only in future
    Offer.where(accepted: 'yes').each do |offer|
      update_applicant_to_placement_accepted(offer.applicant)
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
    chosen_applicant_pool = Applicant.chosen.pluck(:id)
    last_lottery_number = Applicant.chosen.last.lottery_number
    chosen_applicant_pool.each do |applicant_id|
      if Applicant.find(applicant_id).pickers.any?
        chosen_applicant_pool.delete(applicant_id)
        last_lottery_number += 1
        break if Applicant.find_by(lottery_number: last_lottery_number).blank?
        chosen_applicant_pool.push(Applicant.find_by(lottery_number: last_lottery_number).id)
      end
    end

    chosen_applicants = Applicant.find(chosen_applicant_pool)

    chosen_applicants.each do |applicant|
      applicant.match_to_position
      update_applicant_to_lottery_placed(applicant)
    end

    picked_applicants = Pick.all.pluck(:applicant_id)
    offered_applicants = Offer.all.pluck(:applicant_id)
    chosen_applicant_pool -= picked_applicants
    chosen_applicant_pool -= offered_applicants
    return if chosen_applicant_pool.empty?

    if Position.joins("LEFT OUTER JOIN offers ON offers.position_id = positions.id").where("offers.id IS null").any?
      match_applicants_to_positions
    end
  end

  def all_chosen_applicants
    chosen_applicant_pool = Applicant.chosen.pluck(:id)
    last_lottery_number = Applicant.chosen.last.lottery_number
    chosen_applicant_pool.each do |applicant_id|
      if Applicant.find(applicant_id).pickers.any?
        chosen_applicant_pool.delete(applicant_id)
        last_lottery_number += 1
        break if Applicant.find_by(lottery_number: last_lottery_number).blank?
        chosen_applicant_pool.push(Applicant.find_by(lottery_number: last_lottery_number).id)
      end
    end

    Applicant.find(chosen_applicant_pool)
  end

  def update_applicant_to_lottery_activated(applicant)
    Rails.logger.info "Updating Applicant iCIMS ID #{applicant.icims_id} to employment selection: #{applicant.id}"
    response = Faraday.patch do |req|
      req.url 'https://api.icims.com/customers/6405/applicantworkflows/' + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"C38354"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    unless response.success?
      Rails.logger.error 'ICIMS Update Status to Candidate Employment Selection Failed for: ' + applicant.id.to_s
      Rails.logger.error 'Status: ' + response.status.to_s + ' Body: ' + response.body
    end
  end

  def status_is_new_submission?(applicant)
    response = icims_get(object: 'applicantworkflows', id: applicant.workflow_id)
    Rails.logger.info response['status']['id'].to_s
    response['status']['id'] == 'D10100' ? true : false
  end

  def update_applicant_to_lottery_placed(applicant)
    Rails.logger.info "Updating Applicant iCIMS ID #{applicant.icims_id} to employment selection: #{applicant.id}"
    response = Faraday.patch do |req|
      req.url 'https://api.icims.com/customers/6405/applicantworkflows/' + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"C38356"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    unless response.success?
      Rails.logger.error 'ICIMS Update Status to Candidate Employment Selection Failed for: ' + applicant.id.to_s
      Rails.logger.error 'Status: ' + response.status.to_s + ' Body: ' + response.body
    end
  end

  def update_applicant_to_placement_accepted(applicant)
    Rails.logger.info "Updating Applicant iCIMS ID #{applicant.icims_id} to employment selection: #{applicant.id}"
    response = Faraday.patch do |req|
      req.url 'https://api.icims.com/customers/6405/applicantworkflows/' + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"C36951"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    unless response.success?
      Rails.logger.error 'ICIMS Update Status to Candidate Employment Selection Failed for: ' + applicant.id.to_s
      Rails.logger.error 'Status: ' + response.status.to_s + ' Body: ' + response.body
    end
  end

  def update_applicant_to_lottery_waitlist(applicant)
    Rails.logger.info "Updating Applicant iCIMS ID #{applicant.icims_id} to employment selection: #{applicant.id}"
    response = Faraday.patch do |req|
      req.url 'https://api.icims.com/customers/6405/applicantworkflows/' + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"C51162"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    unless response.success?
      Rails.logger.error 'ICIMS Update Status to Candidate Employment Selection Failed for: ' + applicant.id.to_s
      Rails.logger.error 'Status: ' + response.status.to_s + ' Body: ' + response.body
    end
  end

  def update_applicant_to_lottery_expired(applicant)
    Rails.logger.info "Updating Applicant iCIMS ID #{applicant.icims_id} to employment selection: #{applicant.id}"
    response = Faraday.patch do |req|
      req.url 'https://api.icims.com/customers/6405/applicantworkflows/' + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"C38355"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    unless response.success?
      Rails.logger.error 'ICIMS Update Status to Candidate Employment Selection Failed for: ' + applicant.id.to_s
      Rails.logger.error 'Status: ' + response.status.to_s + ' Body: ' + response.body
    end
  end
end
