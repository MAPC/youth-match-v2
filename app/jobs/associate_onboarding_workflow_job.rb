require 'csv'
class AssociateOnboardingWorkflowJob < ApplicationJob
  queue_as :default

  def perform(*args)
    download_update
  end

  private

  def download_update
    Net::SFTP.start('ftp.icims.com', 'boston7884', :password => Rails.application.secrets.icims_sftp_password) do |sftp|
     data = sftp.download!('/Upload/export.05.08.2017.csv')
     csv = CSV.parse(data, headers: true, encoding: 'ISO-8859-1')
     csv.each do |row|
      associate_onboarding_with_position(row['Person : System ID'], row['Onboard Workflow ID'])
    end
   end
  end

  def associate_onboarding_with_position(applicant_id, onboard_workflow)
    position = get_position(applicant_id)
    return nil if position.blank?
    Rails.logger.info "Associate applicant iCIMS ID #{applicant.icims_id} with position: #{applicant.id}"
    response = Faraday.patch do |req|
      req.url "https://api.icims.com/customers/7383/onboardworkflows/#{onboard_workflow}"
      req.body = %Q{ { "job":#{position.icims_id} } }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    unless response.success?
      Rails.logger.error 'ICIMS Associate Applicant Onboard Workflow with Position Failed for: ' + applicant.id.to_s
      Rails.logger.error response.status
      Rails.logger.error response.body
    end
  end

  def get_position(applicant_id)
    pick = Pick.find_by(applicant_id: applicant_id)
    if pick.blank?
      Rails.logger.error "No pick found for applicant: #{applicant_id}"
      return nil
    end
    Position.find(pick.position_id)
  end
end
