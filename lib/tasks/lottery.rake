require 'csv'

LOTTERY_DATE = DateTime.new(2017, 6, 23)

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
      preference = Preference.find_by(applicant: applicant, position: applicant.offers.order(:created_at).last.position)
      puts "Applicant ICIMS ID: #{applicant.icims_id}, Applicant: #{applicant.email}, Position ICIMS ID: #{applicant.offers.order(:created_at).last.position.icims_id}, Position Title: #{applicant.offers.order(:created_at).last.position.title}, Score: #{preference.score}, Travel Time Score: #{preference.travel_time_score}, Applicant Interests: #{applicant.interests}, Open Positions: #{applicant.offers.order(:created_at).last.position.open_positions}, Prefers Nearby: #{applicant.prefers_nearby}"
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
    Offer.where(accepted: 'yes', created_at: LOTTERY_DATE.midnight..LOTTERY_DATE.end_of_day).each do |offer|
      offer.applicant.update(lottery_activated: false)
      UpdateAcceptApplicantsJob.perform_later(offer.id)
    end
  end

  desc 'Update status of candidates that declined their job offers'
  task update_declined_candidates: :environment do
    Offer.where(accepted: 'no_bottom_waitlist', created_at: LOTTERY_DATE.midnight..LOTTERY_DATE.end_of_day).each do |offer|
      offer.applicant.update(lottery_activated: false)
      UpdateDeclineApplicantsJob.perform_later(offer.id)
    end
  end

  desc 'Update status of candidates that failed to respond to job offers'
  task update_expired_candidates: :environment do
    Offer.where(accepted: 'waiting', created_at: LOTTERY_DATE.midnight..LOTTERY_DATE.end_of_day).each do |offer|
      offer.update(accepted: 'expired')
      offer.applicant.update(lottery_activated: false)
      UpdateExpiredApplicantsJob.perform_later(offer.id)
    end
  end

  desc 'Update status of chosen candidates for this round'
  task update_matched_candidates: :environment do
    Applicant.chosen.each do |applicant|
      UpdatePlacedApplicantsJob.perform_later(applicant.id)
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

  desc 'Associate Missing Onboard Workflows with Lottery Positions'
  task associate_missing_lottery_onboard_workflows: :environment do
    csv_text = File.read(Rails.root.join('lib', 'import', 'missing_onboarding_workflows_2.csv'))
    csv = CSV.parse(csv_text, headers: true, encoding: 'ISO-8859-1')
    csv.each do |row|
      AssociateOnboardingWorkflowJob.perform_later(row['Person : System ID'], row['Onboard Workflow ID'])
    end
  end
end
