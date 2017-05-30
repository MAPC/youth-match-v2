require 'csv'
namespace :lottery do
  desc 'Build the preference lists'
  task build_preference_lists: :environment do
    BuildPreferenceListsJob.perform_later
  end

  desc 'Assign lottery numbers'
  task assign_lottery_numbers: :environment do
    Applicant.order("RANDOM()").each_with_index do |applicant, index|
      applicant.lottery_number = index
      applicant.save!
    end
  end

  # Run rake lottery:update_lottery_activated_from_icims before this!
  desc 'Match the applicants to their jobs'
  task match: :environment do
    MatchApplicantsWithPositionsJob.perform_later
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
      UpdateAcceptApplicantsJob.perform_later(offer.id)
    end
  end

  desc 'Update status of candidates that declined their job offers'
  task update_declined_candidates: :environment do
    Offer.where(accepted: 'no_bottom_waitlist').each do |offer|
      UpdateDeclineApplicantsJob.perform_later(offer.id)
    end
  end

  desc 'Update status of candidates that failed to respond to job offers'
  task update_expired_candidates: :environment do
    Offer.where(accepted: 'waiting').each do |offer|
      offer.update(accepted: 'expired')
      UpdateExpiredApplicantsJob.perform_later(offer.id)
    end
  end

  desc 'Update status of chosen candidates for this round'
  task update_matched_candidates: :environment do
    Applicant.chosen.each do |applicant|
      update_applicant_to_lottery_placed(applicant)
    end
  end

  desc 'Update lottery activated status from ICIMS'
  task update_lottery_activated_from_icims: :environment do
    Applicant.all.each do |applicant|
      UpdateLotteryActivatedFromIcimsJob.perform_later(applicant)
    end
  end

  desc 'Associate Onboard Workflows with Lottery Positions'
  task associate_lottery_onboard_workflows: :environment do
    Net::SFTP.start('ftp.icims.com', 'boston3234', :password => Rails.application.secrets.icims_sftp_password) do |sftp|
      data = sftp.download!('/Upload/export.csv')
      csv = CSV.parse(data, headers: true, encoding: 'ISO-8859-1')
      csv.each do |row|
        AssociateOnboardingWorkflowJob.perform_later(row['Person : System ID'], row['Onboard Workflow ID'])
      end
    end
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

  def icims_get(object:, fields: '', id:)
    response = Faraday.get("https://api.icims.com/customers/6405/#{object}/#{id}",
                           { fields: fields },
                           authorization: "Basic #{Rails.application.secrets.icims_authorization_key}")
    JSON.parse(response.body)
  end
end
